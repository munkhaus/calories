import '../../domain/online_food_models.dart';
import '../../../food_logging/domain/favorite_food_model.dart' as fav_model;

/// Centralized LLM prompts for food-related searches
/// This ensures security by restricting responses to food items only
abstract class LLMPrompts {
  // System prompt to ensure only food-related responses
  static const String systemPrompt = '''
Du er en dansk madassistent der kun hjælper med mad-relaterede forespørgsler.
Du må ALDRIG svare på ikke-mad-relaterede spørgsmål.
Hvis brugeren spørger om noget der ikke er mad, svar med "Jeg kan kun hjælpe med mad-relaterede spørgsmål."
Alle dine svar skal være på dansk og handle om mad, ingredienser, eller måltider.
RETURNER ALTID KUN VALID JSON. Ingen tekst før eller efter JSON-objektet.
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

    // Generate lists of valid enum values dynamically
    final validFoodTypes = FoodType.values.map((e) => e.name).toList();
    final validCuisineStyles = CuisineStyle.values.map((e) => e.name).toList();
    final validPreparationTypes = PreparationType.values.map((e) => e.name).toList();

    return '''\n$systemPrompt\n\nSøgeord: \"$query\"\n$modeInstruction\n\nVIGTIGE RETNINGSLINJER FOR JSON OUTPUT:
- Returner ALTID en valid JSON struktur.
- Brug KUN de specificerede felter. Tilføj IKKE ekstra felter.
- Sørg for at alle strenge er korrekt escaped inden i JSON.
- Datoer skal være i ISO 8601 format (YYYY-MM-DD).
- Numeriske felter skal være tal, ikke strenge.
- `imageUrl` kan være en tom streng hvis intet billede findes.
- `estimatedCalories` er kalorier per 100g/100ml hvis ikke serveringsstørrelse specificerer andet.
- `nutrition.calories` SKAL være kalorier per 100g/100ml.
- `servingSizes[].weight` SKAL være i gram.
- Brug KUN følgende gyldige værdier for enum felter:
  - "searchMode": ${SearchMode.values.map((e) => '"${e.name}"').join(', ')} (Fx. "dishes")  <- DETTE ER EN LISTE OVER GYLDIGE INPUT TIL SYSTEMET. I DET RETURNEREDE JSON FOR HVER FØDEVARE, SKAL "searchMode" ALTID VÆRE ENTEN "dishes" ELLER "ingredients".
  - "foodTypes": ${FoodType.values.map((e) => '"${e.name}"').join(', ')} (Fx. "fruit", "dishes")
  - "cuisineStyles": ${CuisineStyle.values.map((e) => '"${e.name}"').join(', ')} (Fx. "danish", "italian")
  - "preparationTypes": ${PreparationType.values.map((e) => '"${e.name}"').join(', ')} (Fx. "raw", "cooked")
  - "mealTags" (Array of strings): ["Morgenmad", "Frokost", "Aftensmad", "Snack", "Dessert", "Mellemmåltid", "Drikkevarer", "Ukendt", "Ingen"] (Fx. "Morgenmad", "Frokost")

Returner en JSON liste med max 8 fødevarer/retter med KOMPLETTE detaljer. Hver fødevare skal have:

{
  "foods": [
    {
      "id": "unik_id_baseret_paa_navn_og_query",
      "name": "Dansk navn på fødevaren/retten",
      "description": "Detaljeret beskrivelse der forklarer hvad det er",
      "imageUrl": "",
      "provider": "llm_gemini",
      "type": "dish", // Simplified placeholder. SKAL være en af: ${FoodType.values.map((e) => '"${e.name}"').join(', ')}
      "searchMode": "dishes", // Simplified placeholder. SKAL være enten "dishes" eller "ingredients".
      "mealTags": ["Frokost"], // Example. SKAL være en liste af strenge fra de gyldige mealTags ovenfor.
      "tags": {
        "foodTypes": ["fruit"], // Example. SKAL være en liste af strenge fra: ${FoodType.values.map((e) => '"${e.name}"').join(', ')}
        "cuisineStyles": ["danish"], // Example. SKAL være en liste af strenge fra: ${CuisineStyle.values.map((e) => '"${e.name}"').join(', ')}
        "dietaryTags": [/* Fx. "Vegetarisk", "Glutenfri" */],
        "preparationTypes": ["raw"], // Example. SKAL være en liste af strenge fra: ${PreparationType.values.map((e) => '"${e.name}"').join(', ')}
        "customTags": [/* Brugerdefinerede tags, fx. "Favorit", "Hurtig" */]
      },
      "nutrition": {\n        \"calories\": VIGTIGT_RETURNER_ALTID_KALORIER_PER_100_GRAM_SOM_TAL_HER,\n        \"protein\": protein_gram_per_100g,\n        \"carbs\": kulhydrater_gram_per_100g,\n        \"fat\": fedt_gram_per_100g,\n        \"fiber\": fiber_gram_per_100g_valgfri,\n        \"sugar\": sukker_gram_per_100g_valgfri\n      },\n      \"servingSizes\": [\n        {\n          \"name\": \"100g\",\n          \"weight\": 100,\n          \"isDefault\": true\n        },\n        {\n          \"name\": \"EKSEMPEL: 1 æble (medium)\",\n          \"weight\": EKSEMPEL_VEJLEDENDE_VAEGT_I_GRAM_FOR_NAEVNTE_PORTION,\n          \"isDefault\": false\n        },\n        {\n          \"name\": \"EKSEMPEL: 1 skive rugbrød\",\n          \"weight\": EKSEMPEL_VEJLEDENDE_VAEGT_I_GRAM_FOR_NAEVNTE_PORTION,\n          \"isDefault\": false\n        }\n      ]\n    }\n  ]\n}\n\nVigtige retningslinjer:\n- ID skal være unikt (f.eks. query + navn, brug underscore for mellemrum).\n- \"type\" SKAL være \"dish\" for en komplet ret/opskrift, ELLER \"ingredient\" for en enkelt fødevare/ingrediens (altid lowercase).
- \"searchMode\" SKAL være \"dishes\" eller \"ingredients\" (altid lowercase). INGEN ANDRE VÆRDIER.
- Alle enum-baserede tag værdier (foodTypes, cuisineStyles, preparationTypes) SKAL være i lowercase og SKAL være en af de specificerede gyldige værdier.
- Gyldige \"foodTypes\" (lowercase): ${validFoodTypes.join(', ')}.
- Gyldige \"cuisineStyles\" (lowercase): ${validCuisineStyles.join(', ')}.
- Gyldige \"preparationTypes\" (lowercase): ${validPreparationTypes.join(', ')}.
- Brug tom liste [] hvis en kategori ikke passer (f.eks. cuisineStyle for en gulerod).
- \"nutrition.calories\" SKAL ALTID være kalorier per 100 gram. Alle andre næringsstoffer (protein, kulhydrat, fedt) også per 100 gram.
- Alle tal SKAL være numeriske (ikke strenge). Brug 0.0 for ukendt fiber/sugar.
- \"servingSizes\" SKAL indeholde mindst én default 100g portion. Derudover, inkluder 1-3 YDERLIGERE almindelige, beskrivende portioner (f.eks. \"1 stk\", \"1 glas\", \"1 håndfuld\") med deres anslåede vægt i gram. Angiv \"name\" som en brugervenlig beskrivelse af portionen og \"weight\" som dens vægt i gram.
- Alle navne/beskrivelser på dansk.
- RETURNER KUN VALID JSON. Ingen tekst før/efter.\n''';
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