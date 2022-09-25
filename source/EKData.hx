class EKData {
    public static var keysShit:Map<Int, Map<String, Dynamic>> = [ // Ammount of keys = num + 1
		0 => [
                "letters" => ["E"], 
                "anims" => ["UP"], 
                "strumAnims" => ["SPACE"], 
                "pixelAnimIndex" => [4]
            ],
		1 => [
                "letters" => ["A", "D"], 
                "anims" => ["LEFT", "RIGHT"], 
                "strumAnims" => ["LEFT", "RIGHT"], 
                "pixelAnimIndex" => [0, 3]
            ],
		2 => [
                "letters" => ["A", "E", "D"], 
                "anims" => ["LEFT", "UP", "RIGHT"], 
                "strumAnims" => ["LEFT", "SPACE", "RIGHT"], 
                "pixelAnimIndex" => [0, 4, 3]
            ],
		3 => [
                "letters" => ["A", "B", "C", "D"], 
                "anims" => ["LEFT", "DOWN", "UP", "RIGHT"], 
                "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 2, 3]
            ],

		4 => [
                "letters" => ["A", "B", "E", "C", "D"], 
                "anims" => ["LEFT", "DOWN", "UP", "UP", "RIGHT"],
			    "strumAnims" => ["LEFT", "DOWN", "SPACE", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 4, 2, 3]
            ],
		5 => [
                "letters" => ["A", "C", "D", "F", "B", "I"], 
                "anims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"],
			    "strumAnims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"], 
                "pixelAnimIndex" => [0, 2, 3, 5, 1, 8]
            ],
		6 => [
                "letters" => ["A", "C", "D", "E", "F", "B", "I"], 
                "anims" => ["LEFT", "UP", "RIGHT", "UP", "LEFT", "DOWN", "RIGHT"],
			    "strumAnims" => ["LEFT", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "RIGHT"], 
                "pixelAnimIndex" => [0, 2, 3, 4, 5, 1, 8]
            ],
		7 => [
                "letters" => ["A", "B", "C", "D", "F", "G", "H", "I"], 
                "anims" => ["LEFT", "UP", "DOWN", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			    "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 2, 3, 5, 6, 7, 8]
            ],
		8 => [
                "letters" => ["A", "B", "C", "D", "E", "F", "G", "H", "I"], 
                "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
		        "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8]
            ],
		9 => [
                "letters" => ["A", "B", "C", "D", "E", "N", "F", "G", "H", "I"], 
                "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
		        "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 2, 3, 4, 13, 5, 6, 7, 8]
            ],
        10 => [
                "letters" => ["A", "B", "C", "D", "J", "E", "M", "F", "G", "H", "I"], 
                "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
                "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "CIRCLE", "SPACE", "CIRCLE", "LEFT", "DOWN", "UP", "RIGHT"], 
                "pixelAnimIndex" => [0, 1, 2, 3, 9, 4, 12, 5, 6, 7, 8]
            ]
	];
}