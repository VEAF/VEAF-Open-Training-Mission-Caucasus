-- THIS IS THE MAIN TABLE OF PRESETS. 
-- DEFINE THE PRESETS (CRYSTALLISATION) HERE AND REFER TO IT LATER IN THE FILE
-- E.G. [1]  = radioPresets["##RADIO1_01##"],
--
-- THIS SHOULD BE THE ONLY PART OF THIS FILE YOU'LL NEED TO CHANGE IF YOU ONLY CHANGE THE FREQUENCIES
-- TO ADD OR CHANGE AIRCRAFT AND COALITION TEMPLATES, SEE FURTHER BELOW
radioPresets =
{
    -- radio 1 : left radio, red radio, UHF radio
    ["##RADIO1_01##"] = 243.000,
    ["##RADIO1_02##"] = 260.000,
    ["##RADIO1_03##"] = 270.000,
    ["##RADIO1_04##"] = 259.000,
    ["##RADIO1_05##"] = 263.000,
    ["##RADIO1_06##"] = 256.000,
    ["##RADIO1_07##"] = 258.000,
    ["##RADIO1_08##"] = 267.000,
    ["##RADIO1_09##"] = 269.000,
    ["##RADIO1_10##"] = 225.000,
    ["##RADIO1_11##"] = 226.000,
    ["##RADIO1_12##"] = 227.000,
    ["##RADIO1_13##"] = 228.000,
    ["##RADIO1_14##"] = 282.200,
    ["##RADIO1_15##"] = 291.000,
    ["##RADIO1_16##"] = 305.100,
    ["##RADIO1_17##"] = 290.100,
    ["##RADIO1_18##"] = 290.300,
    ["##RADIO1_19##"] = 290.400,
    ["##RADIO1_20##"] = 290.500,

    -- radio 2 : right radio, green radio, V/UHF radio
    ["##RADIO2_01##"] = 121.500,
    ["##RADIO2_02##"] = 120.000,
    ["##RADIO2_03##"] = 120.100,
    ["##RADIO2_04##"] = 120.200,
    ["##RADIO2_05##"] = 120.300,
    ["##RADIO2_06##"] = 120.400,
    ["##RADIO2_07##"] = 120.500,
    ["##RADIO2_08##"] = 120.600,
    ["##RADIO2_09##"] = 120.700,
    ["##RADIO2_10##"] = 120.800,
    ["##RADIO2_11##"] = 120.900,
    ["##RADIO2_12##"] = 121.100,
    ["##RADIO2_13##"] = 121.200,
    ["##RADIO2_14##"] = 121.300,
    ["##RADIO2_15##"] = 121.400,
    ["##RADIO2_16##"] = 121.600,
    ["##RADIO2_17##"] = 121.700,
    ["##RADIO2_18##"] = 118.800,
    ["##RADIO2_19##"] = 118.900,
    ["##RADIO2_20##"] = 118.850,

    -- radio 3 : FM radio
    ["##RADIO3_01##"] = 30.000,
    ["##RADIO3_02##"] = 31.000,
    ["##RADIO3_03##"] = 32.000,
    ["##RADIO3_04##"] = 33.000,
    ["##RADIO3_05##"] = 34.000,
    ["##RADIO3_06##"] = 35.000,
    ["##RADIO3_07##"] = 36.000,
    ["##RADIO3_08##"] = 37.000,
    ["##RADIO3_09##"] = 38.000,
    ["##RADIO3_10##"] = 39.000,
    ["##RADIO3_11##"] = 40.000,
    ["##RADIO3_12##"] = 41.000,
    ["##RADIO3_13##"] = 42.000,
    ["##RADIO3_14##"] = 43.000,
    ["##RADIO3_15##"] = 44.000,
    ["##RADIO3_16##"] = 45.000,
    ["##RADIO3_17##"] = 46.000,
    ["##RADIO3_18##"] = 47.000,
    ["##RADIO3_19##"] = 48.000,
    ["##RADIO3_20##"] = 49.000,
    ["##RADIO3_21##"] = 50.000,
    ["##RADIO3_22##"] = 51.000,
    ["##RADIO3_23##"] = 52.000,
    ["##RADIO3_24##"] = 53.000,
    ["##RADIO3_25##"] = 54.000,
    ["##RADIO3_26##"] = 55.000,
    ["##RADIO3_27##"] = 56.000,
    ["##RADIO3_28##"] = 57.000,
    ["##RADIO3_29##"] = 58.000,
    ["##RADIO3_30##"] = 59.000
}

-- THIS IS THE TABLE OF RADIO SETTINGS. 
-- MAKE USE OF THE RADIO PRESETS DEFINED EARLIER IF YOU WANT
-- BY SETTING THE VALUE OF THE type, coalition, AND country PARAMETERS, YOU CAN TARGET A TEMPLATE TO A SPECIFIC GROUP OF AIRCRAFTS
radioSettings =
{
    ["blue F-14B"] =
    {
        type = "F-14B",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO2_01##"],
                    [2]  = radioPresets["##RADIO2_02##"],
                    [3]  = radioPresets["##RADIO2_03##"],
                    [4]  = radioPresets["##RADIO2_04##"],
                    [5]  = radioPresets["##RADIO2_05##"],
                    [6]  = radioPresets["##RADIO2_06##"],
                    [7]  = radioPresets["##RADIO2_07##"],
                    [8]  = radioPresets["##RADIO2_08##"],
                    [9]  = radioPresets["##RADIO2_09##"],
                    [10] = radioPresets["##RADIO2_10##"],
                    [11] = radioPresets["##RADIO2_11##"],
                    [12] = radioPresets["##RADIO2_12##"],
                    [13] = radioPresets["##RADIO2_13##"],
                    [14] = radioPresets["##RADIO2_14##"],
                    [15] = radioPresets["##RADIO2_15##"],
                    [16] = radioPresets["##RADIO2_16##"],
                    [17] = radioPresets["##RADIO2_17##"],
                    [18] = radioPresets["##RADIO2_18##"],
                    [19] = radioPresets["##RADIO2_19##"],
                    [20] = radioPresets["##RADIO2_20##"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue T-45"] =
    {
        type = "T-45",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },
    
    ["blue F/A-18C"] =
    {
        type = "FA-18C_hornet",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO2_01##"],
                    [2]  = radioPresets["##RADIO2_02##"],
                    [3]  = radioPresets["##RADIO2_03##"],
                    [4]  = radioPresets["##RADIO2_04##"],
                    [5]  = radioPresets["##RADIO2_05##"],
                    [6]  = radioPresets["##RADIO2_06##"],
                    [7]  = radioPresets["##RADIO2_07##"],
                    [8]  = radioPresets["##RADIO2_08##"],
                    [9]  = radioPresets["##RADIO2_09##"],
                    [10] = radioPresets["##RADIO2_10##"],
                    [11] = radioPresets["##RADIO2_11##"],
                    [12] = radioPresets["##RADIO2_12##"],
                    [13] = radioPresets["##RADIO2_13##"],
                    [14] = radioPresets["##RADIO2_14##"],
                    [15] = radioPresets["##RADIO2_15##"],
                    [16] = radioPresets["##RADIO2_16##"],
                    [17] = radioPresets["##RADIO2_17##"],
                    [18] = radioPresets["##RADIO2_18##"],
                    [19] = radioPresets["##RADIO2_19##"],
                    [20] = radioPresets["##RADIO2_20##"],
                }, -- end of ["channels"]
            }, -- end of [2]
        }
    },

    ["blue F-16C"] =
    {
        type = "F-16C_50",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO2_01##"],
                    [2]  = radioPresets["##RADIO2_02##"],
                    [3]  = radioPresets["##RADIO2_03##"],
                    [4]  = radioPresets["##RADIO2_04##"],
                    [5]  = radioPresets["##RADIO2_05##"],
                    [6]  = radioPresets["##RADIO2_06##"],
                    [7]  = radioPresets["##RADIO2_07##"],
                    [8]  = radioPresets["##RADIO2_08##"],
                    [9]  = radioPresets["##RADIO2_09##"],
                    [10] = radioPresets["##RADIO2_10##"],
                    [11] = radioPresets["##RADIO2_11##"],
                    [12] = radioPresets["##RADIO2_12##"],
                    [13] = radioPresets["##RADIO2_13##"],
                    [14] = radioPresets["##RADIO2_14##"],
                    [15] = radioPresets["##RADIO2_15##"],
                    [16] = radioPresets["##RADIO2_16##"],
                    [17] = radioPresets["##RADIO2_17##"],
                    [18] = radioPresets["##RADIO2_18##"],
                    [19] = radioPresets["##RADIO2_19##"],
                    [20] = radioPresets["##RADIO2_20##"],
                }, -- end of ["channels"]
            }, -- end of [2]
        }
    },

    ["blue Mirage"] =
    {
        type = "M-2000C",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO2_01##"],
                    [2]  = radioPresets["##RADIO2_02##"],
                    [3]  = radioPresets["##RADIO2_03##"],
                    [4]  = radioPresets["##RADIO2_04##"],
                    [5]  = radioPresets["##RADIO2_05##"],
                    [6]  = radioPresets["##RADIO2_06##"],
                    [7]  = radioPresets["##RADIO2_07##"],
                    [8]  = radioPresets["##RADIO2_08##"],
                    [9]  = radioPresets["##RADIO2_09##"],
                    [10] = radioPresets["##RADIO2_10##"],
                    [11] = radioPresets["##RADIO2_11##"],
                    [12] = radioPresets["##RADIO2_12##"],
                    [13] = radioPresets["##RADIO2_13##"],
                    [14] = radioPresets["##RADIO2_14##"],
                    [15] = radioPresets["##RADIO2_15##"],
                    [16] = radioPresets["##RADIO2_16##"],
                    [17] = radioPresets["##RADIO2_17##"],
                    [18] = radioPresets["##RADIO2_18##"],
                    [19] = radioPresets["##RADIO2_19##"],
                    [20] = radioPresets["##RADIO2_20##"],
                }, -- end of ["channels"]
            }, -- end of [2]
        }
    },

    ["blue Harrier"] =
    {
        type = "AV8BNA",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO2_01##"],
                    [2]  = radioPresets["##RADIO2_02##"],
                    [3]  = radioPresets["##RADIO2_03##"],
                    [4]  = radioPresets["##RADIO2_04##"],
                    [5]  = radioPresets["##RADIO2_05##"],
                    [6]  = radioPresets["##RADIO2_06##"],
                    [7]  = radioPresets["##RADIO2_07##"],
                    [8]  = radioPresets["##RADIO2_08##"],
                    [9]  = radioPresets["##RADIO2_09##"],
                    [10] = radioPresets["##RADIO2_10##"],
                    [11] = radioPresets["##RADIO2_11##"],
                    [12] = radioPresets["##RADIO2_12##"],
                    [13] = radioPresets["##RADIO2_13##"],
                    [14] = radioPresets["##RADIO2_14##"],
                    [15] = radioPresets["##RADIO2_15##"],
                    [16] = radioPresets["##RADIO2_16##"],
                    [17] = radioPresets["##RADIO2_17##"],
                    [18] = radioPresets["##RADIO2_18##"],
                    [19] = radioPresets["##RADIO2_19##"],
                    [20] = radioPresets["##RADIO2_20##"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
            [3] =
            {
                ["modulations"] =
                {
                    [1] =  1,
                    [2] =  1,
                    [3] =  1,
                    [4] =  1,
                    [5] =  1,
                    [6] =  1,
                    [7] =  1,
                    [8] =  1,
                    [9] =  1,
                    [10] = 1,
                    [11] = 1,
                    [12] = 1,
                    [13] = 1,
                    [14] = 1,
                    [15] = 1,
                    [16] = 1,
                    [17] = 1,
                    [18] = 1,
                    [19] = 1,
                    [20] = 1,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO3_01##"],
                    [2]  = radioPresets["##RADIO3_02##"],
                    [3]  = radioPresets["##RADIO3_03##"],
                    [4]  = radioPresets["##RADIO3_04##"],
                    [5]  = radioPresets["##RADIO3_05##"],
                    [6]  = radioPresets["##RADIO3_06##"],
                    [7]  = radioPresets["##RADIO3_07##"],
                    [8]  = radioPresets["##RADIO3_08##"],
                    [9]  = radioPresets["##RADIO3_09##"],
                    [10] = radioPresets["##RADIO3_10##"],
                    [11] = radioPresets["##RADIO3_11##"],
                    [12] = radioPresets["##RADIO3_12##"],
                    [13] = radioPresets["##RADIO3_13##"],
                    [14] = radioPresets["##RADIO3_14##"],
                    [15] = radioPresets["##RADIO3_15##"],
                    [16] = radioPresets["##RADIO3_16##"],
                    [17] = radioPresets["##RADIO3_17##"],
                    [18] = radioPresets["##RADIO3_18##"],
                    [19] = radioPresets["##RADIO3_19##"],
                    [20] = radioPresets["##RADIO3_20##"],
                    [21] = radioPresets["##RADIO3_21##"],
                    [22] = radioPresets["##RADIO3_22##"],
                    [23] = radioPresets["##RADIO3_23##"],
                    [24] = radioPresets["##RADIO3_24##"],
                    [25] = radioPresets["##RADIO3_25##"],
                    [26] = radioPresets["##RADIO3_26##"],
                    [27] = radioPresets["##RADIO3_27##"],
                    [28] = radioPresets["##RADIO3_28##"],
                    [29] = radioPresets["##RADIO3_29##"],
                    [30] = radioPresets["##RADIO3_30##"],
                                    }, -- end of ["channels"]
            }, -- end of [3]
        }
    },

    ["blue Ka-50"] =
    {
        type = "Ka-50",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO3_01##"],
                    [2]  = radioPresets["##RADIO3_02##"],
                    [3]  = radioPresets["##RADIO3_03##"],
                    [4]  = radioPresets["##RADIO3_04##"],
                    [5]  = radioPresets["##RADIO3_05##"],
                    [6]  = radioPresets["##RADIO3_06##"],
                    [7]  = radioPresets["##RADIO3_07##"],
                    [8]  = radioPresets["##RADIO3_08##"],
                    [9]  = radioPresets["##RADIO3_09##"],
                    [10] = radioPresets["##RADIO3_10##"],
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = 0.441,
                    [2]  = 0.442,
                    [3]  = 0.443,
                    [4]  = 0.444,
                    [5]  = 0.445,
                    [6]  = 0.446,
                    [7]  = 0.447,
                    [8]  = 0.448,
                    [9]  = 0.449,
                    [10] = 0.450,
                    [11] = 0.451,
                    [12] = 0.452,
                    [13] = 0.453,
                    [14] = 0.454,
                    [15] = 0.455,
                    [16] = 0.456,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue Mi-8MT"] =
    {
        type = "Mi-8MT",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            [2] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO3_01##"],
                    [2]  = radioPresets["##RADIO3_02##"],
                    [3]  = radioPresets["##RADIO3_03##"],
                    [4]  = radioPresets["##RADIO3_04##"],
                    [5]  = radioPresets["##RADIO3_05##"],
                    [6]  = radioPresets["##RADIO3_06##"],
                    [7]  = radioPresets["##RADIO3_07##"],
                    [8]  = radioPresets["##RADIO3_08##"],
                    [9]  = radioPresets["##RADIO3_09##"],
                    [10] = radioPresets["##RADIO3_10##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },
    
    ["blue Mi-24P"] =
    {
        type = "Mi-24P",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            [2] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO3_01##"],
                    [2]  = radioPresets["##RADIO3_02##"],
                    [3]  = radioPresets["##RADIO3_03##"],
                    [4]  = radioPresets["##RADIO3_04##"],
                    [5]  = radioPresets["##RADIO3_05##"],
                    [6]  = radioPresets["##RADIO3_06##"],
                    [7]  = radioPresets["##RADIO3_07##"],
                    [8]  = radioPresets["##RADIO3_08##"],
                    [9]  = radioPresets["##RADIO3_09##"],
                    [10] = radioPresets["##RADIO3_10##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },
    
    ["blue Gazelles"] =
    {
        type = "SA342.+",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO3_01##"],
                    [2]  = radioPresets["##RADIO3_02##"],
                    [3]  = radioPresets["##RADIO3_03##"],
                    [4]  = radioPresets["##RADIO3_04##"],
                    [5]  = radioPresets["##RADIO3_05##"],
                    [6]  = radioPresets["##RADIO3_06##"],
                    [7]  = radioPresets["##RADIO3_07##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1]  = 0,
                    [2]  = 0,
                    [3]  = 0,
                    [4]  = 0,
                    [5]  = 0,
                    [6]  = 0,
                    [7]  = 0,
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue MiG-21 Bis"] =
    {
        type = "MiG-21Bis",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },
    ["blue L-39C"] =
    {
        type = "L-39C",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }
    },

    ["blue L-39ZA"] =
    {
        type = "L-39ZA",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],                   
                }, -- end of ["channels"]
            }, -- end of [1]
        }
    },

    ["blue C-101CC"] =
    {
        type = "C-101CC",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue C-101EB"] =
    {
        type = "C-101EB",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue UH-1H"] =
    {
        type = "UH-1H",
        coalition = "blue",
        country = nil,
        ["Radio"] = {
            [1] = {
                ["channels"] = {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue A-4E-C"] =
    {
        type = "A-4E-C",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = radioPresets["##RADIO1_01##"],
                    [2]  = radioPresets["##RADIO1_02##"],
                    [3]  = radioPresets["##RADIO1_03##"],
                    [4]  = radioPresets["##RADIO1_04##"],
                    [5]  = radioPresets["##RADIO1_05##"],
                    [6]  = radioPresets["##RADIO1_06##"],
                    [7]  = radioPresets["##RADIO1_07##"],
                    [8]  = radioPresets["##RADIO1_08##"],
                    [9]  = radioPresets["##RADIO1_09##"],
                    [10] = radioPresets["##RADIO1_10##"],
                    [11] = radioPresets["##RADIO1_11##"],
                    [12] = radioPresets["##RADIO1_12##"],
                    [13] = radioPresets["##RADIO1_13##"],
                    [14] = radioPresets["##RADIO1_14##"],
                    [15] = radioPresets["##RADIO1_15##"],
                    [16] = radioPresets["##RADIO1_16##"],
                    [17] = radioPresets["##RADIO1_17##"],
                    [18] = radioPresets["##RADIO1_18##"],
                    [19] = radioPresets["##RADIO1_19##"],
                    [20] = radioPresets["##RADIO1_20##"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }
    },
}
