dnj = {}

dnj.npc = {
    model = 'a_m_y_business_03',
    coords = vector4(466.8449, -575.3569, 28.4998, 177.5365),
  --  blip = { label = '[BRIGÁDA] ŘIDIČ AUTOBUSU', sprite = 513, color = 5, scale = 0.8 }
}

dnj.depo = vector3(434.78, -646.56, 28.73)

dnj.bmodel = 'bus'
dnj.depoprice = 500

dnj.rewards = {
    min = 200,
    max = 450
}

dnj.mxstops = 8

dnj.spawns = {
    { coords = vector3(463.8560, -607.3105, 28.4997), heading = 213.4441 },
    { coords = vector3(462.2881, -612.2373, 28.4997), heading = 217.9420 },
    { coords = vector3(461.3705, -620.0548, 28.4998), heading = 213.7437 },
}

dnj.stops = { -- -1410.2244, -569.5855, 30.2850, 117.3376
    { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-1410.2244, -569.5855, 30.2850), 
        pedsspawn = vector3(-1411.4515, -550.5594, 30.6520) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-1212.1296, -1218.8550, 7.6001), 
        pedsspawn = vector3(-1226.2596, -1180.8905, 7.7106) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(53.7369, -1533.3556, 29.1667), 
        pedsspawn = vector3(30.2100, -1570.0264, 29.2914) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-154.3453, 6208.6958, 31.2022), 
        pedsspawn = vector3(-178.4387, 6176.4761, 31.4222) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-504.2535, 19.9045, 44.7339), 
        pedsspawn = vector3(-472.5457, 22.5242, 45.2165) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-1421.8965, -87.7564, 52.3203), 
        pedsspawn = vector3(-1441.0848, -106.2386, 50.7941) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(-740.3744, -752.0114, 26.6656), 
        pedsspawn = vector3(-735.5145, -784.6246, 24.7953) -- z kadial pojdu npc k busu
    },
  --[[  { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },
    { 
        coords = vector3(305.5334, -772.7594, 29.2609), 
        pedsspawn = vector3(312.5606, -726.7078, 29.3158) -- z kadial pojdu npc k busu
    },--]]
}

dnj.pds = {
    "a_m_y_business_01", "a_f_y_business_01", "a_m_y_hipster_01", 
    "a_f_y_hipster_01", "a_m_m_tourist_01"
}
