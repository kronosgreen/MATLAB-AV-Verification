import os
import glob
import json
import scipy.io as io

#def createActorMatrix(actor):
    
    #for field in actor:


def convertToMatrix():
    folder_path = 'scenarios\scenarioConversion\jsonFiles'
    for filename in glob.glob(os.path.join(folder_path, '*.json')):
        file = open(filename)
        data = json.load(file)
        
        # io.savemat('temp', data['actorMatrix'])
        # b = io.loadmat('temp')
        # print(b)
        for i in data['actorMatrix']:
            io.savemat('temp', i)
            b = io.loadmat('temp')
            print(b)
            #createActorMatrix(i)
            #for data in i:
                #print([i[data], i[data], i[data]])
                #print(data + " : " + i[data])
            #print('\n')


        file.close()

convertToMatrix()