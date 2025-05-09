import 'package:flutter/material.dart';

class BirdDetailsRepository {
  // Complete database of bird information extracted from your React component
  static final Map<String, Map<String, dynamic>> birdDatabase = {
    "Ashy crowned sparrow lark": {
      "habitat": "Grasslands and open fields",
      "distribution": "South Asia",
      "food": "Seeds and insects",
      "conservation_status": "Least Concern",
      "fun_fact": "Known for its melodious song during the breeding season.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Ashy-crowned_Sparrow_Lark_%28Eremopterix_griseus%29_at_Talegaon_MH_28.JPG/800px-Ashy-crowned_Sparrow_Lark_%28Eremopterix_griseus%29_at_Talegaon_MH_28.JPG",
      "wiki_link": "https://en.wikipedia.org/wiki/Ashy-crowned_sparrow_lark"
    },
    "Asian Openbill": {
      "habitat": "Wetlands and marshes",
      "distribution": "South and Southeast Asia",
      "food": "Mainly snails",
      "conservation_status": "Least Concern",
      "fun_fact": "Has a distinctive gap in its bill, adapted for eating snails.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Asian_Openbill_Anastomus_oscitans.jpg/800px-Asian_Openbill_Anastomus_oscitans.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Asian_openbill"
    },
    "Black-headed ibis": {
      "habitat": "Wetlands and agricultural areas",
      "distribution": "South Asia",
      "food": "Insects, frogs, and fish",
      "conservation_status": "Near Threatened",
      "fun_fact": "Often seen wading in shallow water, probing for food.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Threskiornis_melanocephalus_Kolkata_2011-06-19_002.jpg/800px-Threskiornis_melanocephalus_Kolkata_2011-06-19_002.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Black-headed_ibis"
    },
    "Crow": {
      "habitat": "Varied, including urban areas",
      "distribution": "Widespread",
      "food": "Omnivorous",
      "conservation_status": "Least Concern",
      "fun_fact": "Highly intelligent birds, known for their problem-solving abilities.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Corvus_splendens_Bangalore.jpg/800px-Corvus_splendens_Bangalore.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Crow"
    },
    "Eurasian Coot": {
      "habitat": "Lakes and ponds",
      "distribution": "Europe, Asia, Africa, Australia",
      "food": "Aquatic plants and small animals",
      "conservation_status": "Least Concern",
      "fun_fact": "Known for its distinctive white forehead shield.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Fulica_atra_atra_eating_algae.jpg/800px-Fulica_atra_atra_eating_algae.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Eurasian_coot"
    },
    "Indian Roller": {
      "habitat": "Open grasslands and scrublands",
      "distribution": "South Asia",
      "food": "Insects and small vertebrates",
      "conservation_status": "Least Concern",
      "fun_fact": "Famous for its vibrant blue plumage and acrobatic aerial displays.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Indian_Roller_%28Coracias_benghalensis%29.jpg/800px-Indian_Roller_%28Coracias_benghalensis%29.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Indian_roller"
    },
    "Large-billed Crow": {
      "habitat": "Forests, cultivation, and urban areas",
      "distribution": "Asia",
      "food": "Omnivorous",
      "conservation_status": "Least Concern",
      "fun_fact": "Adaptable and resourceful, often seen scavenging for food.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Corvus_macrorhynchos_050820-002.JPG/800px-Corvus_macrorhynchos_050820-002.JPG",
      "wiki_link": "https://en.wikipedia.org/wiki/Large-billed_crow"
    },
    "Little Cormorant": {
      "habitat": "Wetlands, lakes, and rivers",
      "distribution": "South Asia",
      "food": "Fish",
      "conservation_status": "Least Concern",
      "fun_fact": "Often seen drying its wings after diving for fish.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/LittleCormorant.jpg/800px-LittleCormorant.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Little_cormorant"
    },
    "Paddyfield pipit": {
      "habitat": "Open grasslands and agricultural fields",
      "distribution": "South Asia",
      "food": "Insects and seeds",
      "conservation_status": "Least Concern",
      "fun_fact": "Known for its upright stance and wagging tail.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Paddyfield_Pipit_Anthus_rufulus.jpg/800px-Paddyfield_Pipit_Anthus_rufulus.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Paddyfield_pipit"
    },
    "Painted Stork": {
      "habitat": "Wetlands and rivers",
      "distribution": "Parts of Asia",
      "food": "Fish, frogs, and snakes",
      "conservation_status": "Near Threatened",
      "fun_fact": "Named for their pinkish plumage.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Painted_Stork_Ranganthittu_CD.jpg/800px-Painted_Stork_Ranganthittu_CD.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Painted_stork"
    },
    "Red-wattled lapwing": {
      "habitat": "Wetlands, fields, and grasslands",
      "distribution": "South Asia",
      "food": "Insects and other invertebrates",
      "conservation_status": "Least Concern",
      "fun_fact": "Known for its loud, distinctive call and red facial wattles.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Red-wattled_Lapwing_at_Sultanpur_National_Park.jpg/800px-Red-wattled_Lapwing_at_Sultanpur_National_Park.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Red-wattled_lapwing"
    },
    "Spot-billed Pelican": {
      "habitat": "Large water bodies",
      "distribution": "Southern Asia",
      "food": "Fish",
      "conservation_status": "Near Threatened",
      "fun_fact": "Has a large pouch on its bill for catching fish.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Spot-billed_Pelican_Pelecanus_philippensis.jpg/800px-Spot-billed_Pelican_Pelecanus_philippensis.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Spot-billed_pelican"
    },
    "White-breasted Waterhen": {
      "habitat": "Marshes, ponds, and streams",
      "distribution": "South and Southeast Asia",
      "food": "Insects, seeds, and aquatic plants",
      "conservation_status": "Least Concern",
      "fun_fact": "Often seen walking on floating vegetation.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/White-breasted_Waterhen_RJP.jpg/800px-White-breasted_Waterhen_RJP.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/White-breasted_waterhen"
    },
    "Yellow wattled lapwing": {
      "habitat": "Dry grasslands and open fields",
      "distribution": "India",
      "food": "Insects and small invertebrates",
      "conservation_status": "Least Concern",
      "fun_fact": "Characterized by its bright yellow wattles and loud calls.",
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Yellow-wattled_Lapwing.jpg/800px-Yellow-wattled_Lapwing.jpg",
      "wiki_link": "https://en.wikipedia.org/wiki/Yellow-wattled_lapwing"
    }
  };

  // Function to get bird data by name
  static Map<String, dynamic> getBirdData(String birdName) {
    return birdDatabase[birdName] ?? {};
  }

  // Function to get all bird names
  static List<String> getAllBirdNames() {
    return birdDatabase.keys.toList();
  }

  // Function to get conservation status color
  static Color getStatusColor(String status) {
    switch(status) {
      case "Least Concern":
        return Colors.green.shade100;
      case "Near Threatened":
        return Colors.yellow.shade100;
      case "Vulnerable":
        return Colors.orange.shade100;
      case "Endangered":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // Function to get conservation status text color
  static Color getStatusTextColor(String status) {
    switch(status) {
      case "Least Concern":
        return Colors.green.shade800;
      case "Near Threatened":
        return Colors.yellow.shade800;
      case "Vulnerable":
        return Colors.orange.shade800;
      case "Endangered":
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}