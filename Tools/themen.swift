// Ordnet jeden Begriff aus begriffe.txt einem Thema zu und schreibt die
// Zuordnung als Swift-Tabelle:
//
//   swift Tools/themen.swift > GEGO/Models/ThemeMapping.swift
//
// Hintergrund: Der Handkatalog in ObjectCatalog.swift deckt 40 Gegenstände ab,
// die Erkennung kennt 1303. Ohne Auffangnetz ist alles andere ein Fundpunkt,
// der nie erscheint. Das Thema ist dieses Netz – gröber als ein Handeintrag,
// aber nie leer.
//
// Die Regeln laufen von speziell nach allgemein; die erste, die greift,
// gewinnt. Was durchfällt, wird am Ende auf stderr gemeldet – diese Liste
// gehört abgearbeitet, nicht ignoriert.

import Foundation

let pfad = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Tools/begriffe.txt"
guard let text = try? String(contentsOfFile: pfad, encoding: .utf8) else {
    FileHandle.standardError.write("Begriffsliste nicht gefunden: \(pfad)\n".data(using: .utf8)!)
    exit(1)
}
let begriffe = text.split(separator: "\n").map(String.init).filter { !$0.isEmpty }

// MARK: - Regeln

/// `exact` schlägt `contains`. Innerhalb einer Art gewinnt die frühere Regel.
struct Regel {
    let thema: String
    var exact: Set<String> = []
    var contains: [String] = []
}

let regeln: [Regel] = [

    // Menschen bekommen keinen Fundpunkt. Ein Spiel, das einen Zettel mit
    // Nachhaltigkeitstipp auf einen Menschen klebt, ist übergriffig – egal wie
    // gut der Tipp ist.
    Regel(thema: "excluded", exact: [
        "adult", "baby", "child", "teen", "people", "crowd", "person",
        "bride", "groom", "bridesmaid", "santa_claus", "clown", "acrobat",
        "entertainer", "singer", "deejay", "jockey_horse", "skeleton", "skull",
        "grave", "tattoo", "henna", "handwriting", "screenshot", "diagram",
        "chart", "illustrations", "polka_dots", "art", "graffiti", "painting",
        "figurine", "statue", "doll", "puppet", "mask", "costume", "origami",
        "rangoli", "banner", "flag", "medal", "trophy", "ticket", "coupon",
        "gift_card", "play_card", "passport", "license_plate", "checkbook",
        "credit_card", "money", "currency", "coin", "atm", "casino", "poker",
        "roulette", "dice", "domino", "backgammon", "chess", "puzzles",
        "jigsaw", "videogame", "gamepad", "joystick", "games", "board_game",
        "karaoke", "nightclub", "disco_ball", "theater", "concert", "parade",
        "carnival", "circus", "celebration", "ceremony", "wedding", "graduation",
        "birthday_cake", "conference", "auditorium", "podium", "megaphone",
        "spotlight", "performance", "orchestra", "music", "media", "portal",
        "airshow", "diorama", "dragon_parade", "sunbathing"
    ]),

    // MARK: Werkstoffe – der Kern des Spiels

    // Lebende Bäume sind kein Werkstoff. Vor einer Buche etwas über
    // Altholz-Kategorien zu lesen, ist schräg – also eigenes Thema. Im
    // Holz-Thema bleibt nur, was schon verarbeitet ist.
    Regel(thema: "tree",
          exact: ["tree", "forest", "foliage", "branch", "evergreen", "sequoia",
                  "willow", "bonsai", "jungle", "mangrove", "orchard", "acorn",
                  "blossom", "christmas_tree"],
          contains: ["_tree", "tree_"]),

    // Ohne `contains` – „wood" als Teilzeichenkette fing auch `woodpecker`
    // und `woodwind` ein, und die Tierregel kommt erst später. Ein Specht im
    // Holz-Thema fällt lange nicht auf.
    Regel(thema: "wood",
          exact: ["wood_natural", "wood_processed", "log", "lumber", "plank",
                  "sawdust", "timber", "abacus", "bamboo", "cork"]),

    Regel(thema: "metal",
          exact: ["anvil", "gears", "winch", "pulley", "chain", "wire", "nail",
                  "horseshoe", "rim", "wheel", "propeller", "mast", "pipe",
                  "manhole", "hydrant", "pylon", "fence", "cage", "keg",
                  "barrel", "canister", "tin", "sword"],
          contains: ["metal", "steel", "iron", "copper", "brass", "aluminum"]),

    Regel(thema: "tool",
          exact: ["hammer", "wrench", "screwdriver", "pliers", "axe", "chainsaw",
                  "power_saw", "ratchet", "mallet", "caliper", "measuring_tape",
                  "toolbox", "tool", "corkscrew", "scissors", "knife", "grater",
                  "whisk", "spatula", "ladle", "rolling_pin", "mousetrap",
                  "sewing", "yarn", "rope", "cord", "broom", "mop", "rake",
                  "shovel", "wheelbarrow", "watering_can", "mower", "sprinkler",
                  "clothespin", "clothesline", "compass", "sundial", "anchor",
                  "machine", "paintbrush", "pen", "tripod", "typewriter"]),

    Regel(thema: "glass",
          exact: ["drinking_glass", "raw_glass", "stained_glass", "decanter",
                  "wine_bottle", "hourglass", "jar", "vase", "fishbowl",
                  "aquarium", "fishtank", "terrarium", "porthole", "window",
                  "mirror", "lightbulb_glass", "thermometer", "syringe"],
          contains: ["glass"]),

    Regel(thema: "paper",
          exact: ["book", "newspaper", "magazine", "document", "printed_page",
                  "envelope", "receipt", "calendar", "sticky_note", "cardboard_box",
                  "carton", "paper_bag", "map", "billboards", "poster", "flipchart",
                  "chalkboard", "whiteboard", "easel", "bookshelf", "library",
                  "diploma", "notebook", "matzo", "record", "cd", "cassette",
                  "diskette", "red_envelope", "christmas_decoration", "wreath",
                  "decoration", "streamer", "confetti", "balloon", "gift"]),

    Regel(thema: "textile",
          exact: ["clothing", "textile", "curtain", "pillow", "bedding", "towel",
                  "carpet", "rug", "hammock", "tent", "umbrella", "parachute",
                  "leash", "apron", "bib", "diaper", "swimsuit", "wetsuit",
                  "leotard", "kilt", "kimono", "sari", "gown", "tuxedo", "suit",
                  "military_uniform", "lab_coat", "wedding_dress", "bathrobe",
                  "cloak", "poncho", "hoodie", "jacket", "jeans", "necktie",
                  "bowtie", "scarf", "glove", "glove_other", "mitten", "sock",
                  "earmuffs", "backpack", "purse", "wallet", "luggage", "suitcase",
                  "briefcase", "bag", "sack", "basket_container", "stuffed_animals"],
          contains: ["hat", "cap_", "beanie", "fedora", "sombrero", "turban",
                     "shoe", "boot", "sandal", "sneaker", "loafer", "moccasin",
                     "heel", "flipper", "slipper", "footwear", "headgear",
                     "helmet", "hardhat", "goggles", "swimwear"]),

    Regel(thema: "plastic",
          exact: ["bottle", "container", "crate", "bucket", "jug", "thermos",
                  "straw_drinking", "chewing_gum", "cigarette", "cigar",
                  "smoking_item", "lighter", "pacifier", "blocks", "frisbee",
                  "kite", "balloon_hotair", "lifesaver", "lifejacket",
                  "road_safety_equipment", "safety_vest", "gas_mask", "hose"],
          contains: ["plastic", "toy", "vinyl", "styro"]),

    // MARK: Geräte und Technik

    Regel(thema: "electronics",
          exact: ["computer", "laptop", "phone", "payphone", "television",
                  "printer", "camera", "headphones", "consumer_electronics",
                  "circuit_board", "computer_keyboard", "computer_monitor",
                  "computer_mouse", "computer_tower", "monitor", "keypad",
                  "calculator", "stereo", "speakers_music", "turntable",
                  "microphone", "telescope", "microscope", "binoculars",
                  "optical_equipment", "drone_machine", "robot", "stopwatch",
                  "timepiece", "watch", "clock", "thermostat", "dial",
                  "tachometer", "dashboard", "scoreboard", "weight_scale",
                  "stethoscope", "flashlight", "remote", "router", "solar_panel"]),

    Regel(thema: "appliance",
          exact: ["appliance", "refrigerator", "dishwasher", "laundry_machine",
                  "microwave", "oven", "kitchen_oven", "toaster", "toaster_oven",
                  "blender", "juicer", "vacuum", "kettle", "stove", "grill",
                  "brick_oven", "electric_fan", "iron_clothing", "sewing_machine",
                  "steamer_cookware", "rotisserie", "fondue", "cookware",
                  "pot_cooking", "pan", "cutting_board", "teapot", "jacuzzi",
                  "treadmill", "elevator", "escalator", "printer_3d"]),

    Regel(thema: "energy",
          exact: ["light", "light_bulb", "lamp", "lamppost", "lantern", "candle",
                  "candlestick", "chandelier", "wind_turbine", "windmill",
                  "watermill", "dam", "smokestack", "fire", "flame", "embers",
                  "fireplace", "matches", "firecracker", "fireworks", "sparkler",
                  "pyrotechnics", "extinguisher", "engine_vehicle", "battery",
                  "outlet", "generator"]),

    Regel(thema: "furniture",
          exact: ["furniture", "chair", "chair_other", "armchair", "folding_chair",
                  "swivel_chair", "high_chair", "chaise", "stool", "bench", "sofa",
                  "table", "desk", "cabinet", "closet", "bed", "crib", "cradle",
                  "shelf", "seat", "car_seat", "cubicle", "frame", "cakestand",
                  "coatrack", "dresser", "wardrobe"]),

    // MARK: Wasser, Abfall, Gebäude

    Regel(thema: "water",
          exact: ["water", "water_body", "waterways", "bathroom_faucet",
                  "kitchen_faucet", "kitchen_sink", "washbasin", "shower", "bath",
                  "bathroom", "bathroom_room", "toilet_seat", "pool", "fountain",
                  "geyser", "waterfall", "creek", "river", "lake", "ocean",
                  "shore", "harbour", "dock", "pier", "wetland", "coral_reef",
                  "underwater", "iceberg", "glacier", "ice", "snow", "snowball",
                  "rainbow", "liquid"]),

    Regel(thema: "waste",
          exact: ["trash_can", "dumpster", "landfill", "recycling", "compost",
                  "scrapyard", "shipyard", "junkyard"]),

    Regel(thema: "building",
          exact: ["building", "structure", "domicile", "apartment", "house_single",
                  "skyscraper", "castle", "barn", "shed", "garage", "greenhouse",
                  "silo", "hangar", "boathouse", "houseboat", "igloo", "gazebo",
                  "pergola", "porch", "patio", "balcony", "deck", "roof",
                  "chimney", "door", "stairs", "wall", "brick", "arch", "dome",
                  "tower", "belltower", "clock_tower", "lighthouse", "bridge",
                  "tunnel", "monument", "obelisk", "pyramid", "megalith", "ruins",
                  "cave", "cellar", "attic", "cityscape", "street", "sidewalk",
                  "alley", "crosswalk", "road", "road_other", "dirt_road",
                  "driveway", "path", "trail", "parking_lot", "playground",
                  "skatepark", "stadium", "arena", "museum", "hospital", "school",
                  "classroom", "office_supplies", "storefront", "interior_shop",
                  "restaurant", "bar", "kitchen", "kitchen_room",
                  "kitchen_countertop", "living_room", "dining_room", "bedroom",
                  "interior_room", "garden", "park", "orchard", "vineyard",
                  "farm", "agriculture", "rice_field", "zoo", "aquarium_building",
                  "airport", "train_station", "railroad", "track_rail", "traffic_light",
                  "street_sign", "sign", "mailbox", "birdhouse", "beehive",
                  "scarecrow", "flagpole", "pole", "gargoyle", "sculpture",
                  "health_club", "hotel", "church", "temple", "mosque"]),

    // MARK: Verkehr

    Regel(thema: "vehicle",
          exact: ["vehicle", "conveyance", "automobile", "car", "suv", "van",
                  "jeep", "truck", "semi_truck", "bus", "streetcar", "tramway",
                  "monorail", "train", "train_real", "subway", "bicycle",
                  "motorcycle", "scooter", "moped", "rickshaw", "wagon", "cart",
                  "shopping_cart", "stroller", "wheelchair", "crutch", "stretcher",
                  "tricycle", "atv", "go_kart", "snowmobile", "jetski", "boat",
                  "sailboat", "rowboat", "canoe", "kayak", "speedboat", "yacht",
                  "cruise_ship", "barge", "warship", "submarine_water", "watercraft",
                  "ferry", "airplane", "aircraft", "helicopter", "rocket",
                  "hangglider", "balloon_hotair_vehicle", "ambulance", "firetruck",
                  "police_car", "limousine", "convertible", "sportscar",
                  "formula_one_car", "motorhome", "tractor", "bulldozer",
                  "backhoe", "forklift", "crane_construction", "chairlift",
                  "cableway", "tire", "saddle", "oar", "sled", "skateboard",
                  "rollerskates", "ice_skates", "snowshoe", "surfboard",
                  "snowboard", "bodyboard", "ski_equipment", "ski_boot"]),

    // MARK: Essen

    Regel(thema: "plantFood",
          exact: ["vegetable", "fruit", "citrus_fruit", "berry", "grain", "wheat",
                  "rice", "quinoa", "oatmeal", "cereal", "bean", "pea", "nut",
                  "seed", "herb", "spice", "seasonings", "mushroom", "seaweed",
                  "salad", "coleslaw", "sauerkraut", "pickle", "guacamole",
                  "hummus", "tabbouleh", "edamame", "tapas", "antipasti",
                  "coffee_bean", "sunflower_seeds", "sesame"],
          contains: ["apple", "banana", "orange", "lemon", "lime", "grape",
                     "melon", "berry", "cherry", "peach", "pear", "plum", "fig",
                     "mango", "papaya", "kiwi", "guava", "lychee", "durian",
                     "persimmon", "pomegranate", "apricot", "nectarine",
                     "mandarine", "grapefruit", "passionfruit", "starfruit",
                     "rambutan", "mangosteen", "coconut", "pineapple", "avocado",
                     "tomato", "potato", "carrot", "onion", "garlic", "pepper",
                     "cabbage", "broccoli", "cauliflower", "spinach", "lettuce",
                     "celery", "cucumber", "zucchini", "squash", "pumpkin",
                     "eggplant", "radish", "beet", "turnip", "leek", "asparagus",
                     "artichoke", "corn", "olive", "almond", "cashew", "pecan",
                     "pistachio", "peanut", "walnut", "chestnut", "acorn",
                     "macadamia", "hazelnut", "arugula", "kohlrabi", "daikon",
                     "rhubarb", "taro", "chives", "cilantro", "dill", "rosemary",
                     "lemongrass", "turmeric", "wasabi", "mustard", "habanero",
                     "jalapeno", "green_beans", "cantaloupe", "honeydew",
                     "watermelon", "strawberry", "blueberry", "blackberry",
                     "raspberry", "cranberry"]),

    Regel(thema: "animalFood",
          exact: ["meat", "beef", "steak", "bacon", "ham", "salami", "pepperoni",
                  "sausage", "spareribs", "meatball", "poultry", "fried_chicken",
                  "grilled_chicken", "rotisserie_chicken", "egg", "fried_egg",
                  "scrambled_eggs", "omelet", "yolk", "cheese", "butter", "yogurt",
                  "milk", "cream", "honey", "roe", "caviar", "seafood", "fish_food",
                  "shellfish", "shellfish_prepared", "sushi", "sashimi", "clam",
                  "mussel", "oyster", "scallop", "lobster", "crab", "shrimp",
                  "anchovy", "sardine", "tuna", "salmon", "trout", "mackerel",
                  "seabass", "snapper", "swordfish", "tempura", "satay",
                  "teriyaki", "kebab", "shawarma", "souvlaki", "caprese"]),

    Regel(thema: "processedFood",
          exact: ["food", "dessert", "frozen_dessert", "frozen", "baked_goods",
                  "pastry", "bread", "white_bread", "bagel", "croissant", "pretzel",
                  "naan", "pita", "tortilla", "biscuit", "scone", "muffin", "donut",
                  "cookie", "biscotti", "brownie", "cake", "cake_regular",
                  "cheesecake", "cupcake", "fruitcake", "wedding_cake", "pie",
                  "strudel", "baklava", "tiramisu", "flan", "souffle", "pudding",
                  "jello", "jelly", "marshmallow", "candy", "candy_other",
                  "candy_cane", "lollipop", "taffy", "caramel", "chocolate",
                  "chocolate_chip", "gingerbread", "ice_cream", "popsicle",
                  "milkshake", "smoothie", "popcorn", "fries", "chips", "nachos",
                  "pizza", "hamburger", "hotdog", "sandwich", "burrito", "taco",
                  "quesadilla", "falafel", "samosa", "springroll", "gyoza",
                  "wonton", "dumpling", "pierogi", "ramen", "pasta", "spaghetti",
                  "risotto", "paella", "biryani", "curry", "stir_fry", "soup",
                  "casserole", "crepe", "pancake", "waffle", "bruschetta",
                  "tapioca_pearls", "condiment", "sugar_cube", "easter_egg",
                  "jack_o_lantern", "cocktail_food"]),

    Regel(thema: "drink",
          exact: ["drink", "coffee", "tea_drink", "juice", "soda", "beer", "wine",
                  "red_wine", "white_wine", "sparkling_wine", "liquor", "cocktail",
                  "martini", "margarita", "mojito", "sangria", "tequila", "bubble_tea",
                  "hookah", "mug", "cup", "cocktail_glass"]),

    // MARK: Lebendiges

    Regel(thema: "animal",
          exact: ["animal", "mammal", "feline", "canine", "rodent", "marsupial",
                  "ungulates", "reptile", "amphibian", "bird", "raptor", "insect",
                  "arachnid", "arthropods", "mollusk", "gastropod", "cephalopod",
                  "cetacean", "fish", "nest", "flipper_animal", "conch",
                  "seashell", "starfish", "urchin", "barnacle", "spiderweb",
                  "beekeeping", "hunting", "fishing", "rodeo", "bullfighting",
                  "equestrian", "dressage"],
          contains: ["cat", "dog", "puppy", "kitten", "horse", "cow", "pig",
                     "sheep", "goat", "chicken", "duck", "goose", "bear", "wolf",
                     "fox", "deer", "elk", "moose", "bison", "boar", "rabbit",
                     "hare", "squirrel", "mouse_animal", "rat", "hamster",
                     "gerbil", "ferret", "chinchilla", "hedgehog", "porcupine",
                     "skunk", "raccoon", "otter", "beaver", "badger", "koala",
                     "panda", "lemur", "monkey", "ape", "gorilla", "elephant",
                     "giraffe", "zebra", "rhinoceros", "hippopotamus", "camel",
                     "llama", "alpaca", "donkey", "lion", "tiger", "leopard",
                     "cheetah", "cougar", "lynx", "bobcat", "hyena", "coyote",
                     "kangaroo", "sloth", "armadillo", "anteater", "bat_animal",
                     "whale", "dolphin", "seal", "walrus", "shark", "ray_fish",
                     "octopus", "squid", "jellyfish", "snail", "worm", "slug",
                     "spider", "scorpion", "centipede", "millipede", "ant", "bee",
                     "wasp", "beetle", "scarab", "ladybug", "butterfly", "moth",
                     "dragonfly", "grasshopper", "cricket", "caterpillar",
                     "snake", "lizard", "gecko", "iguana", "chameleon", "turtle",
                     "tortoise", "frog", "toad", "crocodile", "alligator",
                     "dinosaur", "eagle", "hawk", "falcon", "owl", "raven",
                     "crow", "dove", "pigeon", "sparrow", "finch", "robin",
                     "swallow", "swan", "heron", "stork", "crane_bird", "flamingo",
                     "pelican", "penguin", "puffin", "gull", "parrot", "parakeet",
                     "cockatoo", "toucan", "peacock", "ostrich", "vulture",
                     "woodpecker", "hummingbird", "sandpiper", "peregrine",
                     "guppy", "goldfish", "koi", "angelfish", "clownfish",
                     "lionfish", "seahorse", "stingray", "barracuda", "sunfish",
                     "puffer", "terrier", "retriever", "shepherd", "hound",
                     "spaniel", "poodle", "collie", "setter", "beagle", "bulldog",
                     "mastiff", "corgi", "husky", "malamute", "pug", "chihuahua",
                     "dachshund", "dalmatian", "doberman", "rottweiler",
                     "schnauzer", "greyhound", "whippet", "basenji", "basset",
                     "bichon", "pitbull", "vizsla", "weimaraner", "ridgeback",
                     "malinois", "newfoundland", "pomeranian", "samoyed",
                     "sheepdog", "wolfhound", "bernese", "saint_bernard",
                     "prairie_dog", "monitor_lizard", "rattlesnake", "python",
                     "lobster_animal", "crab_animal"]),

    Regel(thema: "plant",
          exact: ["plant", "vegetation", "decorative_plant", "flower", "blossom",
                  "bouquet", "flower_arrangement", "grass", "moss", "shrub",
                  "ferns", "ivy", "clover", "holly", "mistletoe", "cactus",
                  "succulent", "leaf", "petal", "pollen", "hay", "straw_hay",
                  "christmas_tree", "potted_plant"],
          contains: ["rose", "tulip", "daisy", "daffodil", "lily", "orchid",
                     "sunflower", "dahlia", "carnation", "chrysanthemum",
                     "marigold", "petunia", "begonia", "poinsettia", "snapdragon",
                     "cornflower", "dandelion", "iris_flower", "lavender",
                     "peony", "hydrangea", "azalea", "jasmine"]),

    Regel(thema: "landscape",
          exact: ["outdoor", "land", "landscape", "mountain", "hill", "cliff",
                  "canyon", "valley", "desert", "sand", "sand_dune", "beach",
                  "island", "rocks", "rock_climbing", "volcano", "lava", "geothermal",
                  "sky", "blue_sky", "night_sky", "cloudy", "sunset_sunrise",
                  "daytime", "moon", "sun", "celestial_body", "celestial_body_other",
                  "aurora", "storm", "thunderstorm", "lightning", "tornado",
                  "blizzard", "haze", "fog", "rain", "wind", "meadow", "prairie",
                  "tundra", "swamp", "marsh", "field", "pasture"]),

    // MARK: Der Rest

    Regel(thema: "sport",
          exact: ["sport", "sports_equipment", "recreation", "workout", "athletics",
                  "gymnastics", "yoga", "swimming", "diving", "surfing", "skiing",
                  "skating", "ice_skating", "rollerskating", "skateboarding",
                  "snowboarding", "sledding", "hiking", "camping", "cycling",
                  "motocross", "motorsport", "nascar", "grand_prix", "racquet",
                  "ball", "ballgames", "baseball", "baseball_bat", "basketball",
                  "football", "soccer", "rugby", "volleyball", "waterpolo",
                  "softball", "tennis", "ping_pong", "badminton", "golf",
                  "golf_ball", "golf_club", "golf_course", "putt", "bowling",
                  "billiards", "dartboard", "foosball", "archery", "fencing_sport",
                  "boxing", "kickboxing", "wrestling", "sumo", "martial_arts",
                  "hockey", "puck", "cricket_sport", "polo", "hurdle", "barbell",
                  "dumbbell", "trampoline", "seesaw", "swing_playground",
                  "slide_toy", "bleachers", "rink", "track_sport", "paintball",
                  "bungee", "parasailing", "skydiving", "snorkeling", "scuba",
                  "rafting", "kiteboarding", "wakeboarding", "windsurfing",
                  "watersport", "winter_sport", "juggling", "dancing", "ballet",
                  "ballet_dancer", "breakdancing", "bellydance", "hula", "samba",
                  "cheerleading", "acrobatics", "fairground", "amusement_park",
                  "carousel", "ferris_wheel", "rollercoaster", "waterslide",
                  "sandcastle", "snowman", "kite_flying"]),

    Regel(thema: "instrument",
          exact: ["musical_instrument", "guitar", "piano", "violin", "cello",
                  "harp", "drum", "bongo_drum", "tambourine", "xylophone",
                  "accordion", "flute", "clarinet", "saxophone", "trumpet",
                  "trombone", "tuba", "organ_instrument", "ukulele", "banjo",
                  "string_instrument", "brass_music", "woodwind", "bell"]),

    Regel(thema: "hygiene",
          exact: ["medicine", "cosmetic_tool", "soap", "shampoo", "toothbrush",
                  "toothpaste", "razor", "perfume", "makeup", "hairdryer",
                  "eyeglasses", "sunglasses", "jewelry", "tiara", "watch_jewelry"]),

    // Letzte Instanz. Fängt auch ab, was eine künftige iOS-Fassung neu in die
    // Taxonomie aufnimmt – dann erscheint der Begriff wenigstens, statt still
    // zu verschwinden.
    Regel(thema: "stuff", exact: ["material", "object", "thing"]),

    Regel(thema: "tableware",
          exact: ["tableware", "housewares", "utensil", "plate", "bowl", "dish",
                  "fork", "spoon", "chopsticks", "napkin", "placemat",
                  "coaster", "tray", "pitcher", "salt_shaker"]),
]

// MARK: - Zuordnen

var zuordnung: [String: String] = [:]
var offen: [String] = []

for begriff in begriffe {
    var gefunden: String?
    for regel in regeln where regel.exact.contains(begriff) {
        gefunden = regel.thema; break
    }
    if gefunden == nil {
        aussen: for regel in regeln {
            for teil in regel.contains where begriff.contains(teil) {
                gefunden = regel.thema; break aussen
            }
        }
    }
    if let gefunden {
        zuordnung[begriff] = gefunden
    } else {
        offen.append(begriff)
    }
}

// MARK: - Ausgabe

print("""
// Erzeugt von Tools/themen.swift – nicht von Hand ändern.
//
//   swift Tools/themen.swift > GEGO/Models/ThemeMapping.swift
//
// Ordnet jeden Begriff der Erkennung einem Thema zu. Das Thema ist das
// Auffangnetz unter dem Handkatalog: gröber, aber nie leer.

enum ThemeMapping {

    static let byLabel: [String: Theme] = [
""")

for begriff in zuordnung.keys.sorted() where zuordnung[begriff] != "excluded" {
    print("        \"\(begriff)\": .\(zuordnung[begriff]!),")
}

print("""
    ]

    /// Begriffe, die bewusst keinen Fundpunkt bekommen. Menschen vor allem –
    /// ein Spiel, das einen Nachhaltigkeitstipp auf einen Menschen klebt, ist
    /// übergriffig, egal wie gut der Tipp ist.
    static let excluded: Set<String> = [
""")
for begriff in zuordnung.keys.sorted() where zuordnung[begriff] == "excluded" {
    print("        \"\(begriff)\",")
}
print("""
    ]
}
""")

// MARK: - Bericht

var zaehler: [String: Int] = [:]
for thema in zuordnung.values { zaehler[thema, default: 0] += 1 }
var bericht = "\n\(begriffe.count) Begriffe, \(zuordnung.count) zugeordnet, \(offen.count) offen\n"
for (thema, anzahl) in zaehler.sorted(by: { $0.value > $1.value }) {
    bericht += String(format: "  %-16s %4d\n", (thema as NSString).utf8String!, anzahl)
}
if !offen.isEmpty {
    bericht += "\nNoch ohne Thema (\(offen.count)):\n"
    bericht += offen.joined(separator: " ") + "\n"
}
FileHandle.standardError.write(bericht.data(using: .utf8)!)
