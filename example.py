# worth={Transversales3=RUNNING, Transversales4=RUNNING}
# convert=str(worth)
# print(convert)
# connect("devops", "devops21", "t3://10.1.20.14:2041")
# lista = ["Transversales3", "Transversales4"]
# for i in lista:
#     cd('domainRuntime:/ServerLifeCycleRuntimes/' + i)
#     state = cmo.getState()
#     print(state)
#     if(state !== "WARNING"):
#         disconnect()
def disconnect(servidor1, servidor2=''):
    lista = []
    lista.append(servidor1)
    lista.append(servidor2)
    if '' in lista:
        lista.remove('') 
    print(lista)
disconnect("hola Mundo")
