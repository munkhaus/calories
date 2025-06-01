/// Centralized LLM prompts for food-related searches
/// This ensures security by restricting responses to food items only
abstract class LLMPrompts {
  // System prompt to ensure only food-related responses
  static const String systemPrompt = '''
Du er en dansk madassistent der kun hjælper med mad-relaterede forespørgsler.
Du må ALDRIG svare på ikke-mad-relaterede spørgsmål.
Hvis brugeren spørger om noget der ikke er mad, svar med "Jeg kan kun hjælpe med mad-relaterede spørgsmål."
Alle dine svar skal være på dansk og handle om mad, ingredienser, eller måltider.
''';

  // Food search prompt with optional search mode - now includes complete details
  static String getFoodSearchPrompt(String query, {String? searchModeFilter}) {
    String modeInstruction = '';
    
    if (searchModeFilter == 'dishes') {
      modeInstruction = '''
VIGTIGT: Fokuser KUN på færdiglavede retter, måltider og sammensatte madprodukter.
Eksempler: "Spaghetti Bolognese", "Grøntsagssuppe", "Kylling med ris", "Caesar salat"
UNDGÅ: Enkelte ingredienser som "tomat", "kylling", "ris"
''';
    } else if (searchModeFilter == 'ingredients') {
      modeInstruction = '''
VIGTIGT: Fokuser KUN på enkelte fødevarer og ingredienser.
Eksempler: "Tomat", "Kyllingbryst", "Basmati ris", "Parmesan ost"
UNDGÅ: Sammensatte retter som "kylling med ris", "tomatsalat"
''';
    }

    return '''\n$systemPrompt\n\nSøgeord: \"$query\"\n$modeInstruction\n\nReturner en JSON liste med max 8 fødevarer/retter med KOMPLETTE detaljer. Hver fødevare skal have:\n\n{\n  \"foods\": [\n    {\n      \"name\": \"Dansk navn på fødevaren/retten\",\n      \"description\": \"Detaljeret beskrivelse der forklarer hvad det er\",\n      \"type\": \"dish|ingredient\",\n      \"mealTags\": [\"Morgenmad\", \"Frokost\", \"Aftensmad\", \"Snack\", \"Mellemmåltid\", \"Dessert\", \"Drikke\", \"Tilbehør\"],\n      \"categoryTags\": [\"Frugt\", \"Grøntsager\", \"Kød\", \"Fisk\", \"Mejeriprodukter\", \"Brød\", \"Pasta\", \"Ris\", \"Kartofler\", \"Nødder\", \"Bælgfrugter\", \"Olie\", \"Krydderier\", \"Søde sager\", \"Drikkevarer\"],\n      \"nutrition\": {\n        \"calories\": kalorier_per_100g_som_tal,\n        \"protein\": protein_gram_per_100g,\n        \"carbs\": kulhydrater_gram_per_100g,\n        \"fat\": fedt_gram_per_100g,\n        \"fiber\": fiber_gram_per_100g,\n        \"sugar\": sukker_gram_per_100g\n      },\n      \"servingSizes\": [\n        {\n          \"name\": \"Standard portion\",\n          \"weight\": vægt_i_gram,\n          \"isDefault\": true\n        },\n        {\n          \"name\": \"Lille portion\",\n          \"weight\": mindre_vægt_i_gram,\n          \"isDefault\": false\n        },\n        {\n          \"name\": \"Stor portion\",\n          \"weight\": større_vægt_i_gram,\n          \"isDefault\": false\n        }\n      ]\n    }\n  ]\n}\n\nVigtige retningslinjer:\n- Brug kun fødevarer/retter der matcher søgeordet\n- \"type\" skal være \"dish\" for retter eller \"ingredient\" for enkelte fødevarer\n- \"mealTags\" skal indeholde relevante måltider hvor denne mad typisk spises\n- \"categoryTags\" skal indeholde 1-3 relevante kategorier der beskriver madtypen\n- Nutrition værdier skal være realistiske og baseret på danske fødevarer\n- Alle tal skal være numeriske værdier (ikke strenge)\n- Portionsstørrelser skal være realistiske og varierede\n- Alle navne og beskrivelser skal være på dansk\n- Kun valid JSON format\n''';
  }

  // Updated food details prompt
  static String getFoodDetailsPrompt(String foodName) {
    return '''\n$systemPrompt\n\nMadprodukt: \"$foodName\"\n\nHvis dette IKKE er et madprodukt, svar kun med: {\"error\": \"Ikke mad-relateret\"}\n\nHvis det ER et madprodukt, returner detaljeret information i JSON format:\n{\n  \"basicInfo\": {\n    \"id\": \"unik_id_for_produktet\",\n    \"name\": \"Præcist dansk navn\",\n    \"description\": \"Detaljeret beskrivelse på dansk der tydeliggør om det er en ret eller ingrediens\",\n    \"type\": \"dish|ingredient\",\n    \"categoryTags\": [\"Frugt\", \"Grøntsager\", \"Kød\", \"Fisk\", \"Mejeriprodukter\", \"Brød\", \"Pasta\", \"Ris\", \"Kartofler\", \"Nødder\", \"Bælgfrugter\", \"Olie\", \"Krydderier\", \"Søde sager\", \"Drikkevarer\"]\n  },\n  \"nutrition\": {\n    \"calories\": kalorier_per_100g_som_tal,\n    \"protein\": protein_gram_per_100g,\n    \"carbs\": kulhydrater_gram_per_100g,\n    \"fat\": fedt_gram_per_100g,\n    \"fiber\": fiber_gram_per_100g,\n    \"sugar\": sukker_gram_per_100g\n  },\n  \"servingSizes\": [\n    {\n      \"name\": \"Standard portion\",\n      \"weight\": vægt_i_gram,\n      \"isDefault\": true\n    },\n    {\n      \"name\": \"Lille portion\",\n      \"weight\": mindre_vægt_i_gram,\n      \"isDefault\": false\n    },\n    {\n      \"name\": \"Stor portion\",\n      \"weight\": større_vægt_i_gram,\n      \"isDefault\": false\n    },\n    {\n      \"name\": \"Per stk\",\n      \"weight\": vægt_per_styk_hvis_relevant,\n      \"isDefault\": false\n    }\n  ]\n}\n\nVigtige retningslinjer:\n- \"type\" skal være \"dish\" for retter eller \"ingredient\" for enkelte fødevarer\n- \"categoryTags\" skal indeholde 1-3 relevante kategorier der beskriver madtypen\n- Alle tal skal være numeriske værdier (ikke strenge)\n- Alle navne skal være på dansk\n- Portionsstørrelser skal være realistiske og varierede\n- Inkluder mindst 3-4 forskellige portionsstørrelser\n- Kun valid JSON format\n''';
  }

  // Input validation - check if query is food-related
  static bool isFoodRelatedQuery(String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    // Empty or too short queries
    if (lowerQuery.length < 2) return false;
    
    // Common food-related keywords in Danish
    final foodKeywords = [
      // Food categories
      'mad', 'fødevare', 'ingrediens', 'måltid',
      'morgenmad', 'frokost', 'aftensmad', 'snack', 'dessert',
      
      // Food types
      'frugt', 'grøntsag', 'kød', 'fisk', 'brød', 'ost', 'mælk',
      'pasta', 'ris', 'kartoffel', 'salat', 'suppe', 'pizza',
      
      // Cooking methods
      'kogt', 'stegt', 'grillet', 'bagt', 'dampet',
      
      // Meal times
      'morgen', 'middag', 'aften', 'mellem',
      
      // Common food words
      'spise', 'drikke', 'kalorie', 'protein', 'kulhydrat',
    ];
    
    // Check if query contains food-related keywords
    for (final keyword in foodKeywords) {
      if (lowerQuery.contains(keyword)) {
        return true;
      }
    }
    
    // Check for common food item patterns
    final commonFoods = [
      'æble', 'banan', 'appelsin', 'kylling', 'oksekød',
      'laks', 'yoghurt', 'havregryn', 'rugbrød', 'ost',
      'mælk', 'ris', 'pasta', 'kartoffel', 'tomat',
    ];
    
    for (final food in commonFoods) {
      if (lowerQuery.contains(food)) {
        return true;
      }
    }
    
    return false;
  }

  // Sanitize user input to prevent prompt injection
  static String sanitizeInput(String input) {
    final cleaned = input
        // First remove any HTML/script tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove dangerous characters but keep safe ones including Danish chars
        .replaceAll(RegExp(r'[^a-zA-Z0-9\sæøåÆØÅ.,!?\-]'), '')
        .trim();
    
    // Limit length safely
    final maxLength = 100;
    return cleaned.length > maxLength 
        ? cleaned.substring(0, maxLength) 
        : cleaned;
  }

  // Error messages
  static const String nonFoodQueryError = 'Jeg kan kun søge efter mad og madprodukter. Prøv at søge efter noget som "frugt", "kød", eller "brød".';
  static const String invalidInputError = 'Ugyldig søgning. Indtast venligst et navn på et madprodukt.';
  static const String noResultsError = 'Ingen madprodukter fundet for denne søgning.';
} 