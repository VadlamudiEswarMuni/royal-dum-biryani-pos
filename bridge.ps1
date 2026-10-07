$ErrorActionPreference='Stop'
$port=17890
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class RawPrinter {
 [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public class DOCINFO { public string pDocName; public string pOutputFile; public string pDataType; }
 [DllImport("winspool.drv", SetLastError=true, CharSet=CharSet.Unicode)] static extern bool OpenPrinter(string p, out IntPtr h, IntPtr d);
 [DllImport("winspool.drv", SetLastError=true)] static extern bool ClosePrinter(IntPtr h);
 [DllImport("winspool.drv", SetLastError=true, CharSet=CharSet.Unicode)] static extern bool StartDocPrinter(IntPtr h, int level, [In] DOCINFO di);
 [DllImport("winspool.drv", SetLastError=true)] static extern bool EndDocPrinter(IntPtr h);
 [DllImport("winspool.drv", SetLastError=true)] static extern bool StartPagePrinter(IntPtr h);
 [DllImport("winspool.drv", SetLastError=true)] static extern bool EndPagePrinter(IntPtr h);
 [DllImport("winspool.drv", SetLastError=true)] static extern bool WritePrinter(IntPtr h, IntPtr p, int n, out int written);
 public static void Send(string printer, byte[] bytes){
   IntPtr h; if(!OpenPrinter(printer,out h,IntPtr.Zero)) throw new Exception("OpenPrinter failed: "+Marshal.GetLastWin32Error());
   try{ var di=new DOCINFO(); di.pDocName="Royal Dum Biryani Receipt"; di.pDataType="RAW"; if(!StartDocPrinter(h,1,di)) throw new Exception("StartDocPrinter failed");
     try{ if(!StartPagePrinter(h)) throw new Exception("StartPagePrinter failed"); IntPtr p=Marshal.AllocHGlobal(bytes.Length); try{Marshal.Copy(bytes,0,p,bytes.Length); int w; if(!WritePrinter(h,p,bytes.Length,out w)) throw new Exception("WritePrinter failed");} finally{Marshal.FreeHGlobal(p);} EndPagePrinter(h);} finally{EndDocPrinter(h);} }
   finally{ClosePrinter(h);}
 }
}
"@
function Send-Json($ctx,$obj,$status=200){$json=$obj|ConvertTo-Json -Depth 8; $b=[Text.Encoding]::UTF8.GetBytes($json);$ctx.Response.StatusCode=$status;$ctx.Response.ContentType='application/json; charset=utf-8';$ctx.Response.Headers.Add('Access-Control-Allow-Origin','*');$ctx.Response.Headers.Add('Access-Control-Allow-Headers','Content-Type');$ctx.Response.OutputStream.Write($b,0,$b.Length);$ctx.Response.Close()}
function Esc([string]$s){$s -replace "\x1b",""}
function Build-Receipt($o){
 $enc=[Text.Encoding]::ASCII; $ms=New-Object IO.MemoryStream
 function B([byte[]]$x){$ms.Write($x,0,$x.Length)}
 B([byte[]](0x1b,0x40));
 # 80mm H80i layout: about 3mm left margin and a controlled printable width.
 # At ~203 dpi, 24 dots is approximately 3mm. GS L sets the left margin;
 # GS W limits the print area so text does not run to the paper edge.
 B([byte[]](0x1d,0x4c,0x18,0x00));
 B([byte[]](0x1d,0x57,0x10,0x02)); # 528 dots ~= 66mm print area after the 3mm margin
 B([byte[]](0x1b,0x61,0x01)); B([byte[]](0x1b,0x45,0x01)); B($enc.GetBytes("THE ROYAL DUM BIRYANI`n")); B([byte[]](0x1b,0x45,0x00)); B($enc.GetBytes("Restaurant Bill`n")); B([byte[]](0x1b,0x61,0x00));
 B($enc.GetBytes(("Bill No: {0}`nDate: {1} {2}`nType: {3}`n" -f $o.id,$o.date,$o.time,$o.type))); if($o.table){B($enc.GetBytes("Table: $($o.table)`n"));}; B($enc.GetBytes("------------------------------------------`n"));
 foreach($i in $o.items){$line=("{0} x{1}  Rs.{2:N2}" -f (Esc ([string]$i.name)),$i.qty,([double]$i.price*[double]$i.qty)); B($enc.GetBytes($line+"`n"));}
 B($enc.GetBytes("------------------------------------------`n")); B($enc.GetBytes(("Subtotal: Rs.{0:N2}`nDiscount: Rs.{1:N2}`nDelivery: Rs.{2:N2}`n" -f $o.subtotal,$o.discount,$o.delivery))); B([byte[]](0x1b,0x45,0x01)); B($enc.GetBytes(("TOTAL: Rs.{0:N2}`n" -f $o.total))); B([byte[]](0x1b,0x45,0x00)); B($enc.GetBytes("Payment: $($o.payment)`n`n")); B([byte[]](0x1b,0x61,0x01)); B($enc.GetBytes("Thank You! Visit Again.`n`n")); # Feed a small amount, then request a feed-to-cut-position + FULL CUT.
 # GS V 65 0 is the ESC/POS feed-and-full-cut form.
 B([byte[]](0x1b,0x64,0x02)); B([byte[]](0x1d,0x56,0x41,0x00)); return $ms.ToArray()
}
$listener=New-Object Net.HttpListener;$listener.Prefixes.Add("http://127.0.0.1:$port/");$listener.Start();Write-Host "Royal Dum Biryani H80i Print Bridge running on http://127.0.0.1:$port" -ForegroundColor Green
while($listener.IsListening){try{$ctx=$listener.GetContext();$path=$ctx.Request.Url.AbsolutePath;if($ctx.Request.HttpMethod -eq 'OPTIONS'){Send-Json $ctx @{ok=$true};continue};if($path -eq '/printers'){$ps=Get-Printer|Select-Object -ExpandProperty Name;Send-Json $ctx @{ok=$true;printers=$ps};continue};if($path -eq '/print' -and $ctx.Request.HttpMethod -eq 'POST'){$sr=New-Object IO.StreamReader($ctx.Request.InputStream,[Text.Encoding]::UTF8);$body=$sr.ReadToEnd();$o=$body|ConvertFrom-Json;$bytes=Build-Receipt $o;[RawPrinter]::Send([string]$o.printer,$bytes);Send-Json $ctx @{ok=$true;message='Printed'};continue};Send-Json $ctx @{ok=$false;error='Not found'} 404}catch{try{Send-Json $ctx @{ok=$false;error=$_.Exception.Message} 500}catch{}}}
