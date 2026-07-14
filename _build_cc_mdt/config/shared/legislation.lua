return {
    PENAL_CODES = {
        [1] = { NAME = 'Homicidio Doloso Qualificado', ARTICLE = 'Art. 121, §2º, Código Penal', SENTENCE = 120, FINE = 50000, BAIL = false },
        [2] = { NAME = 'Homicidio Doloso', ARTICLE = 'Art. 121, caput, Código Penal', SENTENCE = 90, FINE = 35000, BAIL = false },
        [3] = { NAME = 'Tentativa de Homicidio', ARTICLE = 'Art. 121 c/c Art. 14, II, Código Penal', SENTENCE = 70, FINE = 25000, BAIL = false },
        [4] = { NAME = 'Homicidio Culposo', ARTICLE = 'Art. 121, §3º, Código Penal', SENTENCE = 25, FINE = 12000, BAIL = 80000 },
        [5] = { NAME = 'Homicidio Culposo no Transito', ARTICLE = 'Art. 302, CTB', SENTENCE = 30, FINE = 15000, BAIL = 100000 },
        [6] = { NAME = 'Lesão Corporal', ARTICLE = 'Art. 129, caput, Código Penal', SENTENCE = 20, FINE = 7000, BAIL = 40000 },
        [7] = { NAME = 'Lesão Corporal Grave', ARTICLE = 'Art. 129, §1º, Código Penal', SENTENCE = 35, FINE = 12000, BAIL = 70000 },
        [8] = { NAME = 'Lesão Corporal Gravissima', ARTICLE = 'Art. 129, §2º, Código Penal', SENTENCE = 50, FINE = 18000, BAIL = false },
        [9] = { NAME = 'Terrorismo', ARTICLE = 'Art. 2º, Lei 13.260/2016', SENTENCE = 150, FINE = 75000, BAIL = false },
        [10] = { NAME = 'Sequestro e Cárcere Privado', ARTICLE = 'Art. 148, Código Penal', SENTENCE = 60, FINE = 25000, BAIL = false },
        [11] = { NAME = 'Extorsão Mediante Sequestro', ARTICLE = 'Art. 159, Código Penal', SENTENCE = 140, FINE = 70000, BAIL = false },
        [12] = { NAME = 'Ocultação de Cadáver', ARTICLE = 'Art. 211, Código Penal', SENTENCE = 35, FINE = 15000, BAIL = false },

        [13] = { NAME = 'Furto', ARTICLE = 'Art. 155, caput, Código Penal', SENTENCE = 25, FINE = 10000, BAIL = 50000 },
        [14] = { NAME = 'Furto Qualificado', ARTICLE = 'Art. 155, §4º, Código Penal', SENTENCE = 40, FINE = 18000, BAIL = 90000 },
        [15] = { NAME = 'Furto a Caixa Eletrônico', ARTICLE = 'Art. 155, §4º-A, Código Penal', SENTENCE = 65, FINE = 30000, BAIL = false },
        [16] = { NAME = 'Roubo', ARTICLE = 'Art. 157, caput, Código Penal', SENTENCE = 40, FINE = 15000, BAIL = 85000 },
        [17] = { NAME = 'Roubo Majorado', ARTICLE = 'Art. 157, §2º, Código Penal', SENTENCE = 60, FINE = 25000, BAIL = false },
        [18] = { NAME = 'Roubo de Veículos', ARTICLE = 'Art. 157, Código Penal', SENTENCE = 45, FINE = 18000, BAIL = 95000 },
        [19] = { NAME = 'Roubo a Loja', ARTICLE = 'Art. 157, Código Penal', SENTENCE = 50, FINE = 20000, BAIL = 100000 },
        [20] = { NAME = 'Roubo a Joalheria', ARTICLE = 'Art. 157, Código Penal', SENTENCE = 80, FINE = 40000, BAIL = false },
        [21] = { NAME = 'Roubo a Banco', ARTICLE = 'Art. 157, Código Penal', SENTENCE = 110, FINE = 60000, BAIL = false },
        [22] = { NAME = 'Latrocínio', ARTICLE = 'Art. 157, §3º, Código Penal', SENTENCE = 160, FINE = 80000, BAIL = false },
        [23] = { NAME = 'Extorsão', ARTICLE = 'Art. 158, Código Penal', SENTENCE = 50, FINE = 22000, BAIL = false },

        [24] = { NAME = 'Receptação', ARTICLE = 'Art. 180, caput, Código Penal', SENTENCE = 30, FINE = 12000, BAIL = 60000 },
        [25] = { NAME = 'Receptação Qualificada', ARTICLE = 'Art. 180, §1º, Código Penal', SENTENCE = 50, FINE = 22000, BAIL = false },
        [26] = { NAME = 'Desmanche de Veículos', ARTICLE = 'Art. 180, §6º, Código Penal', SENTENCE = 55, FINE = 22000, BAIL = 120000 },
        [27] = { NAME = 'Dano ao Patrimônio', ARTICLE = 'Art. 163, Código Penal', SENTENCE = 12, FINE = 7000, BAIL = 25000 },
        [28] = { NAME = 'Dano Qualificado', ARTICLE = 'Art. 163, parágrafo único, Código Penal', SENTENCE = 25, FINE = 12000, BAIL = 50000 },
        [29] = { NAME = 'Incêndio Criminoso', ARTICLE = 'Art. 250, Código Penal', SENTENCE = 70, FINE = 30000, BAIL = false },
        [30] = { NAME = 'Violação de Domicílio', ARTICLE = 'Art. 150, Código Penal', SENTENCE = 10, FINE = 5000, BAIL = 20000 },

        [31] = { NAME = 'Lavagem de Dinheiro', ARTICLE = 'Art. 1º, Lei 9.613/1998', SENTENCE = 70, FINE = 45000, BAIL = false },
        [32] = { NAME = 'Associação Criminosa', ARTICLE = 'Art. 288, Código Penal', SENTENCE = 35, FINE = 15000, BAIL = false },
        [33] = { NAME = 'Organização Criminosa', ARTICLE = 'Art. 2º, Lei 12.850/2013', SENTENCE = 80, FINE = 35000, BAIL = false },
        [34] = { NAME = 'Favorecimento Pessoal', ARTICLE = 'Art. 348, Código Penal', SENTENCE = 15, FINE = 7000, BAIL = 25000 },
        [35] = { NAME = 'Favorecimento Real', ARTICLE = 'Art. 349, Código Penal', SENTENCE = 20, FINE = 9000, BAIL = 35000 },
        [36] = { NAME = 'Fraude Processual', ARTICLE = 'Art. 347, Código Penal', SENTENCE = 25, FINE = 12000, BAIL = 45000 },
        [37] = { NAME = 'Falsa Identidade', ARTICLE = 'Art. 307, Código Penal', SENTENCE = 15, FINE = 8000, BAIL = 25000 },
        [38] = { NAME = 'Uso de Documento Falso', ARTICLE = 'Art. 304, Código Penal', SENTENCE = 35, FINE = 15000, BAIL = false },
        [39] = { NAME = 'Corrupção Ativa', ARTICLE = 'Art. 333, Código Penal', SENTENCE = 50, FINE = 25000, BAIL = false },
        [40] = { NAME = 'Corrupção Passiva', ARTICLE = 'Art. 317, Código Penal', SENTENCE = 55, FINE = 28000, BAIL = false },

        [41] = { NAME = 'Desobediência', ARTICLE = 'Art. 330, Código Penal', SENTENCE = 10, FINE = 4000, BAIL = 15000 },
        [42] = { NAME = 'Desacato', ARTICLE = 'Art. 331, Código Penal', SENTENCE = 12, FINE = 5000, BAIL = 18000 },
        [43] = { NAME = 'Resistência', ARTICLE = 'Art. 329, Código Penal', SENTENCE = 20, FINE = 9000, BAIL = 30000 },
        [44] = { NAME = 'Omissão de Socorro', ARTICLE = 'Art. 135, Código Penal', SENTENCE = 12, FINE = 7000, BAIL = 20000 },
        [45] = { NAME = 'Maus-Tratos', ARTICLE = 'Art. 136, Código Penal', SENTENCE = 18, FINE = 9000, BAIL = 30000 },

        [46] = { NAME = 'Porte Ilegal de Arma de Fogo', ARTICLE = 'Art. 14, Lei 10.826/2003', SENTENCE = 35, FINE = 18000, BAIL = 85000 },
        [47] = { NAME = 'Posse Irregular de Arma de Fogo', ARTICLE = 'Art. 12, Lei 10.826/2003', SENTENCE = 20, FINE = 10000, BAIL = 45000 },
        [48] = { NAME = 'Porte de Arma de Uso Restrito', ARTICLE = 'Art. 16, Lei 10.826/2003', SENTENCE = 65, FINE = 30000, BAIL = false },
        [49] = { NAME = 'Posse de Peças de Armas', ARTICLE = 'Art. 16, Lei 10.826/2003', SENTENCE = 35, FINE = 20000, BAIL = 90000 },
        [50] = { NAME = 'Tráfico de Armas', ARTICLE = 'Art. 17, Lei 10.826/2003', SENTENCE = 100, FINE = 50000, BAIL = false },
        [51] = { NAME = 'Tráfico Internacional de Armas', ARTICLE = 'Art. 18, Lei 10.826/2003', SENTENCE = 120, FINE = 60000, BAIL = false },
        [52] = { NAME = 'Tráfico de Munição', ARTICLE = 'Art. 17, Lei 10.826/2003', SENTENCE = 80, FINE = 35000, BAIL = false },
        [53] = { NAME = 'Disparo de Arma de Fogo', ARTICLE = 'Art. 15, Lei 10.826/2003', SENTENCE = 30, FINE = 15000, BAIL = 60000 },

        [54] = { NAME = 'Posse de Entorpecentes', ARTICLE = 'Art. 28, Lei 11.343/2006', SENTENCE = 10, FINE = 8000, BAIL = 30000 },
        [55] = { NAME = 'Tráfico de Drogas', ARTICLE = 'Art. 33, Lei 11.343/2006', SENTENCE = 90, FINE = 35000, BAIL = false },
        [56] = { NAME = 'Associação para o Tráfico', ARTICLE = 'Art. 35, Lei 11.343/2006', SENTENCE = 70, FINE = 30000, BAIL = false },

        [57] = { NAME = 'Direção Perigosa', ARTICLE = 'Art. 175, CTB', SENTENCE = 5, FINE = 20000, BAIL = 25000 },
        [58] = { NAME = 'Embriaguez ao Volante', ARTICLE = 'Art. 306, CTB', SENTENCE = 20, FINE = 12000, BAIL = 45000 },
        [59] = { NAME = 'Racha', ARTICLE = 'Art. 308, CTB', SENTENCE = 25, FINE = 15000, BAIL = 50000 },
        [60] = { NAME = 'Fuga de Abordagem', ARTICLE = 'Art. 195, CTB', SENTENCE = 8, FINE = 7000, BAIL = 20000 }
    }, 
    AGGRAVATING_FACTORS = {
        [1] = { NAME = 'Resistência à prisão', PERCENTAGE = 30 },
        [2] = { NAME = 'Criminoso reincidente', PERCENTAGE = 20 },
        [3] = { NAME = 'Uso de arma de fogo', PERCENTAGE = 25 },
        [4] = { NAME = 'Crime cometido em concurso de pessoas', PERCENTAGE = 20 },
        [5] = { NAME = 'Crime cometido com refém', PERCENTAGE = 40 }
    },
    ATTENUANTS_FACTORS = {
        [1] = { NAME = 'Réu primário', PERCENTAGE = 15 },
        [2] = { NAME = 'Confissão espontânea', PERCENTAGE = 15 },
        [3] = { NAME = 'Colaboração com a investigação', PERCENTAGE = 20 },
        [4] = { NAME = 'Bom comportamento durante a abordagem', PERCENTAGE = 10 },
        [5] = { NAME = 'Tentativa sem consumação do crime', PERCENTAGE = 20 }
    }, 
    TRAFFIC_TICKETS = {
        [1] = { NAME = 'Excesso de Velocidade', ARTICLE = 'Art. 218, CTB', FINE = 5000 },
        [2] = { NAME = 'Avanço de Sinal Vermelho', ARTICLE = 'Art. 208, CTB', FINE = 7000 },
        [3] = { NAME = 'Estacionamento Proibido', ARTICLE = 'Art. 181, CTB', FINE = 3000 },
        [4] = { NAME = 'Uso de Celular ao Volante', ARTICLE = 'Art. 252, CTB', FINE = 4000 },
        [5] = { NAME = 'Dirigir Sem Cinto de Segurança', ARTICLE = 'Art. 167, CTB', FINE = 3500 }
    },
    SENTENCE = {
        MAXIMUM = 100
    }
}