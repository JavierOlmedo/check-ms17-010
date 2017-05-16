#Script para comprobar vulnerabilidad MS17-010

#Autor: Javier Olmedo
#Twitter: @JJavierOlmedo
#http://hackpuntes.com
#16/05/2017

#ID de actualizaciones que deben de estar instaladas en el sistema para evitar la propagación de WannaCry
$actualizaciones = ("KB4012212", "KB4012217", "KB4015551", "KB4019216", "KB4012216", "KB4015550", "KB4019215", "KB4013429", "KB4019472", "KB4015217", "KB4015438", "KB4016635")

#Obtenemos los equipos que estén habilitados en el dominio y los ordenamos alfabéticamente
$equipos = Get-ADComputer -Filter {enabled -eq $true} -Property * | sort

#Bucle para recorrer los equipos
foreach ($equipo in $equipos){

    #Hacemos un ping al equipo para comprobar si está encendido antes de comprobarlo
    $nombreequipo = $equipo.Name
    $ping = gwmi win32_pingstatus -f "Address = '$nombreequipo'" 
    
    #Si el equipo hace ping
    if($ping.statuscode -eq 0) {
    
        #Intentamos comprobar las actualizaciones
        try { 

            $comprobaractualizaciones = Get-HotFix -ComputerName $nombreequipo | Where-Object {$actualizaciones -contains $_.HotfixID} | Select-Object -property "HotFixID"

            if($comprobaractualizaciones) {
                Write-Host -foregroundcolor Green "El equipo $nombreequipo no es vulnerable"
            } else {
                Write-Host -foregroundcolor Red "El equipo $nombreequipo es vulnerable"
            }
                 
       #Si nos da error al comprobar las actualizaciones     
       } catch { 
            Write-Host -foregroundcolor Red "El equipo $nombreequipo está encendido, pero no se puede comprobar las actualizaciones" 
       #
       } 
 
    #Si el equipo no responde a ping
    } else { 
            Write-Host -foregroundcolor Red "El equipo $nombreequipo está apagado o no responde a ping"
    }     
}
