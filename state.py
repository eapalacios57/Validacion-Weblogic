#Conexión a Consola Weblogic
connect("devops","devops21","t3://10.1.5.153:3041")

#Validar Estado del Servidor weblogic 12.0.1.3(Cluster)
retMap=state ("Cluster_Transversales2", returnMap="true")

