extends Node
class_name MarkovChain
## I configured an existing Markov Chain model from:
## https://github.com/cyberfilth/fantasy-names-generator/blob/master/Markov/Markov.gd
## ^^^ The original was in Godot 3 (I think), so I changed some stuff
## to fit the coding conventions I know in Godot 4. The model was also
## in First Order, so I tweaked some stuff to make it any level of Order.
## The choosing of the next letter was also equally randomized
## and not weighted, so I changed that.


## Begins name generation with common starting letters, according to the training data.
## Removing START_TOKEN would require you to randomly pick a starting letter.
## Without START_TOKEN, I don't think you can have high Order Chains.
const START_TOKEN : String = "^"

## Exits name generation earlier if this character is pulled.
## Without NULL_TOKEN, I think generated names would always be of [member MAX_CHARACTER_LENGTH] length.
const NULL_TOKEN : String = "$"

## Level of Order or "realism" in the names.
## The level of Order dictates how far the Chain looks at previous letters.
## EX: name == "ZTIER"
## ORDER == 1 ---> "T" looks one letter behind, which is "Z"
## ORDER == 2 ---> "I" looks two letters behind, which is "ZT"
## ORDER == n ---> current letter looks n letters behind

## Higher level generally yields more realistic names according to the training data,
## but the list would need to have more entries (name length or number of names) for more variation.
## Higher level but low entries ---> similar sounding names.

## First Order (1) ---> would make you go "wow, that's a something name."
## Second Order (2) ---> decent, like 70% are names you'd understand.
## Third Order (3) ---> Good middle ground if you have around 1000 different entries in the training data.
## nth Order (n) ---> Higher realism (according to your training data), but needs more entries.
##                                    ^^^ this means if you have a lot of "ark" in your list
##                                    (EX: "Park", "Mark", "Bark", "Dark", "Hark", "Tark"),
##                                    the Chain would recognize that that pattern appears quite frequently
##                                    and will imitate it more frequently, which is why
##                                    you need variation in your data.
const ORDER : int = 3

const MIN_CHARACTER_LENGTH : int = 3 ## Minimum character length for the name.
const MAX_CHARACTER_LENGTH : int = 7 ## Maximum character length for the name.

## Weight increment of possible next letter weights.
## This can be any value, but 1.0 works just fine.
const WEIGHT_INCREMENT : float = 1.0 


## Training data.
var names : Array[String] = [
	"Parker", "Zaid", "Teagan", "Harry", "Laylani", "Julius", "Talia", "Forrest", "Holly", "Jeffery",
	"Bellamy", "Mordechai", "Madelynn", "Jaxx", "Skylar", "Jair", "Jazlyn", "Dawson", "Yaretzi", "Benjamin",
	"Nina", "Danny", "Emelia", "Lennox", "Aubrey", "Dilan", "Valeria", "Jack", "Marceline", "Douglas",
	"Braelynn", "Rylan", "Dane", "Evelynn", "Rene", "Anais", "Tomas", "Briana", "Thaddeus", "Macy",
	"Richard", "Ember", "Titan", "Raelynn", "Walker", "Raegan", "Thiago", "Kali", "Archie", "Brooke",
	"Elisha", "Mercy", "Jameson", "Paityn", "Weston", "Kimberly", "Cal", "Rosalia", "Maxwell", "Evie",
	"Cassius", "Keyla", "Caleb", "Hope", "Kareem", "Finley", "Alonso", "Zara", "Aries", "Alyssa",
	"Caden", "Chloe", "Landyn", "Elisabeth", "Quinton", "Lilly", "Gideon", "Kiana", "Javier", "Stevie",
	"Greyson", "Haylee", "Harley", "Yasmin", "Osiris", "Kara", "Eduardo", "Lucia", "Jaiden", "Selena",
	"Grey", "Zaylee", "Ephraim", "Mckinley", "Jorge", "Lilah", "Marshall", "Etta", "Cole", "Carolyn",
	"Brock", "Donovan", "Oaklynn", "Daniel", "Elliot", "Remington", "Kylie", "Fox", "Lillian", "Bodie",
	"Lyra", "Tristan", "Raya", "King", "Kyra", "Cora", "Jayceon", "Mazikee", "Julian", "Johanna",
	"Brayan", "Khalani", "Brixton", "Virginia", "Mitchell", "Ariana", "Boston", "Charley", "Royal", "Rowan",
	"Jayden", "Sloan", "Casen", "Katherine", "Brendan", "Elodie", "Bo", "Oaklee", "Colten", "Ramona",
	"Jada", "Cayden", "Estella", "Rex", "Braden", "Lea", "Corbin", "Nola", "Ellis", "Brylee",
	"Vincent", "Allyson", "Brecken", "Alma", "Westin", "Marlee", "Edward", "Mckenzie", "Samson", "Alondra",
	"Cason", "Belle", "Anderson", "Ailani", "Waylon", "Ashlyn", "Lena", "Justice", "Aileen", "Marcelo",
	"Calliope", "Louis", "Saoirse", "Noe", "Nicolas", "Dylan", "Cristian", "Lydia", "Luca", "Callie",
	"Ocean", "Karina", "Kristopher", "Nova", "Ermias", "Avayah", "Ryder", "Saylor", "Johan", "Reign",
	"Michaela", "Wilson", "Ainsley", "Cory", "Ben", "Aubriella", "Dominik", "Phoenix", "Anders", "Lorelai",
	"Corey", "Emely", "Lionel", "Alaia", "Leon", "Adalynn", "Atticus", "Waverly", "Rey", "Raven",
	"Colter", "Zoey", "Layne", "Jemma", "Alice", "Finn", "Kathryn", "Matias", "Maryam", "Leonard",
	"Sutton", "Jane", "Blaise", "Dahlia", "Micah", "Landry", "Conrad", "Ensley", "Raymond", "Davina",
	"Declan", "Beau", "Jordyn", "Hassan", "Miriam", "Graham", "Angela", "Bjorn", "Alana", "Peter",
	"Ashlynn", "Princeton", "Zhuri", "Grant", "Hamza", "Anika", "Charles", "Miranda", "Kasen", "Ariel",
	"Vance", "Bennett", "Marcellus", "April", "Graysen", "Dorothy", "Eric", "Alicia", "Terrance", "Reagan",
	"Theodore", "Sylvia", "Ronald", "June", "Maverick", "Briella", "Elijah", "Mariah", "Braylon", "Tiana",
	"Pierce", "Annabella", "Kylan", "Margo", "Elian", "Bronson", "Miracle", "Rome", "Marlowe", "Penelope",
	"Arjun", "Mary", "Fabian", "Colette", "Giovanni", "Liberty", "Malik", "Adrianna", "Sylas", "Marilyn",
	"Erik", "Clarissa", "Oakley", "Duke", "Linda", "Paxton", "Magdalena", "Lian", "Alina", "Conner",
	"Stormi", "Damir", "Adelynn", "Ian", "Sophie", "Amias", "Ezra", "Finnley", "Jazmin", "Amani",
	"Caspian", "Ryan", "Yehuda", "Isabela", "Trey", "Violet", "Kohen", "Zahra", "Miller", "Michelle",
	"Damian", "Gracelyn", "Gordon", "Aliza", "Henrik", "Daphne", "Blaine", "Noelle", "Abby", "Axton",
	"Kane", "Anya", "Ty", "Aisha", "Riggs", "Kataleya", "Blaze", "Emmalyn", "Niklaus", "Nia",
	"Khalil", "Luciana", "Kamila", "Armani", "Legacy", "Aziel", "Ford", "Cali", "Promise", "Xavier",
	"Sky", "Kade", "Scarlet", "Kayson", "Addison", "Kolton", "Maia", "Adalee", "Reed", "Mackenzie",
	"Jaylen", "Denver", "Seth", "Leighton", "Dakota", "Charlie", "Gracie", "Tommy", "Kora", "Gemma",
	"Chance", "Natalia", "Leo", "Stephanie", "Anakin", "Amirah", "Ryland", "Mylah", "Jared", "Crystal",
	"Lane", "Artemis", "Andres", "Miley", "Kristian", "Maria", "Peyton", "Alessia", "Malaya", "Johnny",
	"Milan", "Ayaan", "Penny", "Dangelo", "Rivka", "Lorenzo", "Beckett", "Mckenna", "Harrison", "Iris",
	"Clay", "Cadence", "Milana", "Jamie", "Hattie", "August", "Marianna", "Whitney", "Frankie", "Melanie",
	"Khari", "Isabel", "Bryson", "Whitley", "Philip", "Edith", "Jesus", "Amber", "Axel", "Helen",
	"Emmy", "Harris", "Summer", "Ava", "Drake", "Tori", "Liam", "Amelie", "Kaiden", "Carmen",
	"Collin", "Valery", "Caiden", "Amalia", "Magnus", "Callan", "Rafael", "Milani", "Ryker", "Jagger",
	"Kamryn", "Maison", "Kaisley", "Elliott", "Madelyn", "Marlon", "Esme", "Eden", "Molly", "Zeke",
	"Vienna", "Jakob", "Autumn", "Leandro", "Savannah", "Kameron", "Erin", "Kyng", "Kyler", "Aarav",
	"Ameer", "Daniela", "Halo", "Wilder", "Leilany", "Zechariah", "Kendra", "Malakai", "Megan", "Addilyn",
	"Macie", "Emersyn", "Nora", "Emory", "Berkley", "Isaiah", "Azalea", "Baker", "Gwen", "Bryce",
	"Daniella", "Ray", "Marisol", "Willie", "Laila", "Joaquin", "Sloane", "Jakobe", "Eileen", "Jaxxon",
	"Alexis", "Oscar", "Bailey", "Arian", "Natalie", "Matthew", "Victor", "Amaya", "Thomas", "Millie",
	"Christian", "Aron", "Sydney", "Kinsley", "Veda", "Zain", "Mae", "David", "Bethany", "Rudy",
	"Nyomi", "Fisher", "Dalary", "Thalia", "Ahmad", "Braylee", "Noor", "Jon", "Adelina", "Isaac",
	"Reyna", "Salem", "Phoebe", "Shiloh", "Hunter", "Dante", "Byron", "Astrid", "Bruce", "Freya",
	"Camden", "Scout", "Kyleigh", "Meadow", "Jay", "Princess", "Cayson", "Lola", "Caroline", "Mack",
	"Neil", "Delaney", "Jakari", "Audrey", "Raphael", "Mateo", "Sonny", "Alora", "Joel", "Iliana",
	"Yousef", "Emilia", "Gianni", "Lucille", "Franco", "Leonardo", "Emerie", "Lewis", "Capri", "Luis",
	"Zora", "Alistair", "Lacey", "Oliver", "Aaliyah", "Laney", "Liliana", "Dakari", "Keily", "London",
	"Tinsley", "Korbin", "Queen", "Jacqueline", "Francis", "Meredith", "Arturo", "Amaia", "Zachariah", "Denisse",
	"Dior", "Wyatt", "Vada", "Ibrahim", "Meilani", "Koda", "Benicio", "Fallon", "Rosa", "Malcolm",
	"Joyce", "Edison", "Piper", "Hank", "Evangeline", "Ophelia", "Danna", "Seven", "Gloria", "Ainhoa",
	"Reginald", "Norah", "Rocky", "Everleigh", "Jayson", "Emery", "Jamison", "Yamileth", "Phillip", "Mallory",
	"Noah", "Rhea", "Benson", "Kenna", "Grayson", "Cecelia", "Eliezer", "Genesis", "Zachary", "Aya",
	"Maurice", "Oakleigh", "Kenji", "Amiyah", "Remy", "Zaniyah", "Jolie", "Jones", "Octavia", "Georgia",
	"Cruz", "Maximiliano", "Elsie", "Santino", "Matthias", "Myra", "Jesse", "Angel", "Alfredo", "Lance",
	"Zuri", "Abram", "Lara", "Clayton", "Alanna", "Nolan", "Amanda", "Travis", "Greta", "Anaya",
	"Rayden", "Ada", "Ramon", "Scarlett", "Karsyn", "Taylor", "Nataly", "Laurel", "Erick", "Ariya",
	"Augustine", "Lyric", "Demi", "Sevyn", "Jericho", "Luisa", "Camilo", "Nathalia", "Leanna", "Leonel",
	"Saige", "Abdiel", "Lia", "Jacob", "Shay", "Israel", "Sariah", "Isla", "Galilea", "Armando",
	"Rosalie", "Ivan", "Ledger", "Tristen", "Kaydence", "Kinslee", "Kenneth", "Will", "Kaliyah", "Maximilian",
	"Analia", "Sara", "Joey", "Rosie", "Maddox", "Paloma", "Damien", "Vivienne", "Brady", "Celeste",
	"Isaias", "Camille", "Spencer", "Salvatore", "Khloe", "Boone", "Fiona", "Zelda", "Adriel", "Journee",
	"Justin", "Zahir", "Eithan", "Charlotte", "Kendrick", "Niko", "Grady", "Mikayla", "Andy", "Kian",
	"Kyson", "Kendall", "Flynn", "Rose", "Blair", "James", "Anne", "Tyler", "Amy", "Franklin",
	"Trace", "Glenn", "Weaver", "Ahmed", "Odom", "Lowe", "Neal", "Hubbard", "Hammond", "Whitney", "O’Donnell",
	"Richmond", "Farmer", "Landry", "Morales", "Bernard", "Villarreal", "Dunn", "Floyd", "Miller", "Lambert",
	"Cochran", "Adkins", "Little", "Parker", "Conrad", "Chen", "Lee", "Sierra", "Huerta", "Newton",
	"Hurley", "McFarland", "Caldwell", "Hester", "Benton", "Baxter", "Hood", "Palacios", "Anthony", "Bradley",
	"Daniels", "Rubio", "Russell", "Santos", "Dominguez", "Snyder", "Carlson", "Cannon", "Rios", "Enriquez",
	"Sellers", "Ward", "Terrell", "Schmidt", "Lim", "Macdonald", "Kennedy", "Wade", "Barton", "Quintero",
	"Hansen", "Velez", "Arnold", "David", "Carroll", "Dunlap", "Spencer", "Nunez", "Clark", "Singleton",
	"Jarvis", "Callahan", "Carpenter", "Campos", "Rivers", "Maldonado", "Robbins", "Watson", "Barr", "Alfaro",
	"Delarosa", "Harrell", "Beck", "Silva", "Baldwin", "Greene", "Davila", "Foley", "Archer", "Mercado",
	"Li", "Ortega", "Leon", "Dodson", "Ellis", "Maynard", "Kane", "Wolfe", "Newman", "Wilson",
	"Roth", "Willis", "Tran", "Crane", "Rivera", "Lam", "Patrick", "Meyer", "Frye", "Holmes",
	"Arroyo", "Travis", "King", "Villa", "Donovan", "Ashley", "Hoover", "McClain", "Clayton", "Yates",
	"Carr", "Torres", "Mathews", "Vance", "Stevens", "Hobbs", "Brennan", "Marsh", "Huynh", "Merritt",
	"Esparza", "Brock", "Harvey", "McClure", "Hancock", "Leblanc", "Cortes", "Jennings", "Pineda", "Bates",
	"Pruitt", "Reynolds", "Vincent", "Cuevas", "Leach", "Fitzgerald", "Payne", "McCoy", "Petersen", "Conner",
	"Atkins", "Tang", "Pratt", "Perry", "Wilcox", "Sims", "Benitez", "Ponce", "Roy", "Singh",
	"Blackwell", "Garrison", "Person", "Byrd", "Myers", "Gutierrez", "Sloan", "Stark", "Nguyen", "Gates",
	"Hayden", "Butler", "Mejia", "Yoder", "Tapia", "Horn", "Parks", "Nixon", "Bullock", "Michael",
	"Booker", "Lucas", "Weeks", "French", "Lloyd", "Heath", "Graham", "Grant", "Jordan", "Barry",
	"Magana", "Cardenas", "Dudley", "Young", "Mora", "Stone", "Hogan", "Lane", "Buchanan", "Wilkinson",
	"Jensen", "McCarty", "McDaniel", "Coleman", "Pugh", "Charles", "Underwood", "Schneider", "Richard", "Henderson",
	"Gardner", "Hardin", "Burton", "Rice", "Franklin", "McKee", "Acevedo", "O’Connor", "Hendrix", "Armstrong",
	"Phelps", "Kemp", "Stokes", "Saunders", "Hawkins", "Proctor", "Powell", "McGuire", "Farley", "Griffith",
	"Church", "Simmons", "Thompson", "Casey", "Shepherd", "Mills", "Carter", "Schultz", "Brown", "Holland",
	"Parrish", "Fitzpatrick", "Kramer", "Strong", "Steele", "Solis", "Cherry", "Horne", "May", "Ali",
	"Cross", "Lindsey", "Wyatt", "Davenport", "Houston", "Bruce", "Pacheco", "Fry", "Calderon", "Atkinson",
	"Knapp", "Bishop", "Daugherty", "Hicks", "McGee", "Stuart", "Brandt", "Holt", "Chavez", "Howard",
	"Beard", "Huff", "Roach", "Brady", "House", "Spears", "Pitts", "Abbott", "Bass", "Orr",
	"Rich", "Barnes", "Stanley", "Vo", "Rollins", "Wiley", "Herring", "Paul", "Gould", "Elliott",
	"Copeland", "Ball", "Farrell", "Sparks", "Jaramillo", "Winters", "Berg", "Moses", "Strickland", "Hanson",
	"Ochoa", "Terry", "Harrington", "Norman", "Montoya", "Banks", "Alvarez", "McLean", "Barker", "Walton",
	"Day", "Campbell", "Burgess", "Parsons", "Hurst", "Moon", "Avila", "Hamilton", "Manning", "Vega",
	"Knight", "Guevara", "Logan", "Hart", "Wood", "Scott", "McLaughlin", "Cantu", "Moody", "Solomon",
	"Miles", "Peck", "Alvarado", "Cabrera", "McIntosh", "Erickson", "York", "Huang", "Walter", "Peralta",
	"Chung", "Webb", "Howell", "Hayes", "Chan", "Burns", "Corona", "Hinton", "Sullivan", "Choi",
	"Olson", "Romero", "Waller", "Goodman", "Guerra", "Hunt", "Salas", "Bailey", "Swanson", "Henry",
	"Reilly", "Smith", "Gentry", "Christensen", "Castaneda", "Correa", "Lara", "Wilkins", "Stevenson", "Larson",
	"Marquez", "Vargas", "Keith", "Phan", "Simpson", "Rogers", "Velasquez", "Maxwell", "Black", "Boyer",
	"Nielsen", "McMahon", "Brooks", "Fowler", "Escobar", "Duffy", "Joseph", "Contreras", "Rosales", "Stein",
	"Lynn", "Cain", "Keller", "Sherman", "McCormick", "Shaw", "Robinson", "Bradshaw", "Gomez", "Townsend",
	"Hartman", "Guerrero", "Francis", "Mata", "Pollard", "Johnston", "Juarez", "Warren", "Hickman", "Ware",
	"Lowery", "Curtis", "Medrano", "Owens", "Hall", "Stephens", "Morris", "Prince", "Gillespie", "Sheppard",
	"Shah", "Holloway", "Ramirez", "Melendez", "Clements", "Parra", "Combs", "Espinosa", "Buck", "Hill",
	"Morrow", "Hull", "Noble", "Colon", "Salazar", "Dixon", "Nava", "McBride", "Hebert", "Fletcher",
	"Browning", "Watkins", "Peterson", "Avery", "Reyes", "Cobb", "Carey", "Jefferson", "Flores", "Espinoza",
	"Ventura", "Andersen", "Cook", "Wiggins", "Crosby", "McConnell", "Hutchinson", "Schmitt", "Garner", "Bryan",
	"Blackburn", "Mays", "Lewis", "Sampson", "Yang", "McCann", "Collier", "Price", "Hampton", "Montgomery",
	"Richardson", "Warner", "Rocha", "Ruiz", "Cortez", "Hahn", "O’Neill", "Wright", "Lozano", "Rowland",
	"Gaines", "Raymond", "Costa", "Vaughn", "Mosley", "Hensley", "Krueger", "Frazier", "Boyd", "Brewer",
	"George", "Sandoval", "Santana", "Vazquez", "Gross", "Stafford", "Murillo", "Chapman", "Fields", "Shaffer",
	"Blake", "Gregory", "Kline", "Flowers", "Kaur", "Bryant", "Leonard", "Pierce", "Mayo", "Branch",
	"Everett", "Good", "Shelton", "Park", "Anderson", "Mullen", "Baker", "Tucker", "Beltran", "Rasmussen",
	"Hess", "Waters", "Shields", "Golden", "McKay", "Le", "Esquivel", "Zhang", "Oliver", "Figueroa",
	"Andrade", "Klein", "Munoz", "Bernal", "Khan", "Avalos", "Owen", "Aguirre", "Wu", "Barrett",
	"Dickerson", "Vasquez", "Ayala", "Garcia", "Mathis", "Gibson", "Cruz", "Xiong", "Berger", "Salgado",
	"Fritz",
]

## Used for weighted random picks.
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#              "letter combination"
var chain : Dictionary[String, Dictionary] = {}
#                     {possible next letter, weight}


func _ready() -> void:
	randomize()
	_build_markov_chain()


## Returns a String of first name and last name.
## Simply call MarkovChain.generate_name() for a full name.
func generate_name() -> String:
	var first_name : String = _new_name().capitalize()
	var last_name : String = _new_name().capitalize()

	return first_name + " " + last_name


## Builds the Markov chain using the data in [member names].
func _build_markov_chain() -> void:
	for n in names:
		var current_name : String = ""

		# Adds START_TOKEN based on [member ORDER].
		# EX: ORDER == 3 and START_TOKEN == ^ ---> ^^^name
		for i in range(ORDER):
			current_name += START_TOKEN
		current_name += n.to_lower()

		# Loops through every letter combination / "key" in the name based [member ORDER].
		for i in range(current_name.length() - ORDER):
			var name_key : String = ""

			# Gets the current key based on [member ORDER].
			# EX: ORDER == 3 ---> key = "nam"e ; ORDER == 2 ---> key = "na"me
			for j in range(ORDER):
				name_key += current_name[i + j]

			# Next letter after the key.
			# EX: key == "nam"e ---> next_letter = nam"e"
			var next_letter : String = current_name[i + ORDER]

			# Add letter combination to the Markov chain.
			if name_key not in chain:
				chain[name_key] = {}

			# Add possible next letter to the current key with initial weight [member WEIGHT_INCREMENT].
			# EX: Chain has letter "a", and "a" can be followed by "b"
			#     "b" is added to "a"'s possible next letter list
			if next_letter not in chain[name_key]:
				chain[name_key][next_letter] = WEIGHT_INCREMENT

			# Add current weight of current key's next letter with [member WEIGHT_INCREMENT].
			# EX: Chain has letter "c", and "c" can be followed by "d"
			#     "d" is already in "c"'s possible next letter list,
			#     so simply increase its weight value
			else:
				chain[name_key][next_letter] = chain[name_key][next_letter] + WEIGHT_INCREMENT


func _new_name() -> String:
	var character_count : int = 0
	var generated_name : String = ""

	# Adds START_TOKEN based on [member ORDER].
	# EX: ORDER == 3 and START_TOKEN == ^ ---> name_key = ^^^
	var name_key : String = ""
	for i in range(ORDER):
		name_key += START_TOKEN

	while character_count < MAX_CHARACTER_LENGTH:

		# Exit loop if letter combination wasn't found in the Markov Chain.
		if name_key not in chain:
			break

		# Pull next_letter according to name_key's list of possible next letters.
		var next_letter : String = get_next_letter(name_key)

		# Pulled NULL_TOKEN? Don't worry, we have fallbacks!
		if next_letter == NULL_TOKEN:

			# Exit loop if character count satisfied MIN_CHARACTER_LENGTH.
			if character_count > MIN_CHARACTER_LENGTH:
				break

			# Keep pulling new letters until it's not NULL_TOKEN.
			else:
				while next_letter == NULL_TOKEN:
					next_letter = get_next_letter(name_key)

		# Add next_letter to name.
		generated_name += next_letter

		# Update name_key: remove first character and add next_letter.
		# EX: name_key == "nam" and next_letter == "e"
		#     name_key = "am" + "e" = "ame"
		name_key = name_key.erase(0, 1) + next_letter

		# Onwards to next iteration!
		character_count += 1

	# Return the generated name. Why am I documenting this?
	return generated_name


## Pulls a random next letter according to its weights
## from name_key's possible next letters.
func get_next_letter(name_key : String) -> String:
	var possible_next_letters : Dictionary = chain[name_key]

	# Separate the possible next letters from their weights, into their own arrays.
	var letters : PackedStringArray = PackedStringArray(possible_next_letters.keys())
	var weights : PackedFloat32Array = PackedFloat32Array(possible_next_letters.values())

	# Get weighted random index.
	# Higher weight means a higher chance of pull.
	var weighted_index : int = rng.rand_weighted(weights)

	# Return chosen letter.
	return letters[weighted_index]
