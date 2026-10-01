Config = {}

-- Government departments
Config.Departments = {
    {name = 'Police', label = 'Police Department', ranks = {'Officer', 'Sergeant', 'Captain', 'Commissioner'}},
    {name = 'Fire', label = 'Fire Department', ranks = {'Firefighter', 'Lieutenant', 'Captain', 'Chief'}},
    {name = 'Health', label = 'Health Department', ranks = {'Paramedic', 'Doctor', 'Surgeon', 'Director'}}
}

-- Government ranks
Config.Ranks = {
    ['Officer'] = {salary = 5000, permissions = {'arrest', 'ticket'}},
    ['Sergeant'] = {salary = 7000, permissions = {'arrest', 'ticket', 'promote'}},
    ['Captain'] = {salary = 9000, permissions = {'arrest', 'ticket', 'promote', 'demote'}},
    ['Commissioner'] = {salary = 12000, permissions = {'arrest', 'ticket', 'promote', 'demote', 'fire'}}
}

-- Government licenses
Config.Licenses = {
    'driver',
    'weapon',
    'hunting'
}

-- Government application types
Config.Applications = {
    'police',
    'fire',
    'health'
}

-- Government administration settings
Config.Admin = {
    superadmin = 'superadmin',
    admin = 'admin',
    mod = 'mod'
}