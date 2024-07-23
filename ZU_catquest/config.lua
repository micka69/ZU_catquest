Config = {}

Config.StartNPC = {
    model = `a_c_cat_01`,
    coords = vector4(-258.62, -977.23, 31.22 - 1, 205.14),
    blip = {
        sprite = 126,
        color = 3,
        scale = 0.75,
        label = "Parcours du Chat"
    }
}
 
Config.CatModels = {
    `a_c_cat_01`,
}

Config.Checkpoints = {
    {pos = vector3(-256.47, -985.31, 30.44), radius = 1.5, description = "Sortir de la ruelle"},
    {pos = vector3(-242.41, -990.12, 28.51), radius = 1.5, description = "Traverser la route"},
    {pos = vector3(-174.04, -917.03, 28.52), radius = 1.5, description = "Atteindre le banc du parc"},
    {pos = vector3(-137.86, -995.68, 26.50), radius = 1.5, description = "Traverser le chantier"},
    {pos = vector3(-119.87, -1071.35, 24.13), radius = 1.5, description = "Traverser le chantier"},
    {pos = vector3(-66.39, -1090.51, 25.87), radius = 1.5, description = "Aller au concessionnaire"},
    {pos = vector3(237.96, -892.43, 28.88), radius = 1.5, description = "Aller à la place des cubes"},
}
  
Config.Rewards = {
    MinMoney = 100,
    MaxMoney = 1000,
    CatToys = {
        {name = "cat_toy_ball", label = "Balle pour chat", min = 1, max = 3},
        {name = "cat_toy_mouse", label = "Souris en peluche", min = 1, max = 2},
        {name = "cat_toy_laser", label = "Pointeur laser", min = 0, max = 1},
        {name = "cat_toy_scratcher", label = "Griffoir", min = 0, max = 1},
        {name = "cat_toy_feather", label = "Plumeau", min = 1, max = 2}
    }
}

Config.CatAbilities = {
    CrouchSpeed = 1.3  -- Multiplicateur de vitesse en mode furtif
}