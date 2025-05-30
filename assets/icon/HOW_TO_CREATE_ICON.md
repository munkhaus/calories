# Sådan laver du app-ikonet

## Hurtig metode med Canva (GRATIS)

1. Gå til [canva.com](https://canva.com)
2. Søg efter "App Icon" eller vælg "Custom Size" → 1024x1024px
3. Brug denne farvepalet:
   - Primær: #6366F1 (lilla-blå)
   - Sekundær: #EC4899 (pink)
   - Orange: #F59E0B
   - Grøn: #10B981

## Design elementer at inkludere:

### Baggrund
- Gradient fra lilla (#6366F1) til pink (#EC4899)
- Eller solid farve med en af hovedfarverne

### Ikoner (brug Canva's ikon bibliotek):
1. **Mad element** (vælg ét):
   - Kniv og gaffel
   - Tallerken med mad
   - Æble
   - Burger/mad ikon

2. **Aktivitet element** (lille i hjørnet):
   - Løbende figur
   - Hantel
   - Hjerte puls

3. **Kamera element** (meget lille):
   - Kamera ikon
   - Eller spring over hvis for fyldt

### Layout forslag:
```
┌─────────────────┐
│ 📷    [Aktivitet]│
│                 │
│    🍽️           │
│  (Mad ikon)     │
│                 │
│  Kalorie App    │ (valgfrit)
└─────────────────┘
```

## Trin-for-trin i Canva:

1. **Opret nyt design** → App Icon (1024x1024)
2. **Baggrund**: Vælg "Elements" → "Shapes" → Firkant → Farv til gradient eller solid
3. **Hovedikon**: Søg "food" eller "plate" → Vælg et mad-ikon → Centrer det
4. **Aktivitetsikon**: Søg "running" → Gør det lille → Placer i øverste højre hjørne
5. **Kamera** (valgfrit): Søg "camera" → Gør det meget lille → Placer i øverste venstre hjørne
6. **Download**: Som PNG, høj kvalitet

## Efter download:
1. Gem filen som `app_icon.png` i denne mappe
2. Kør: `flutter pub run flutter_launcher_icons:main`
3. Genbyg appen

## Alternativ: Brug AI
Kopier denne prompt til ChatGPT, DALL-E eller Midjourney:

```
Create a modern app icon for a calorie tracking app. 1024x1024 pixels, round corners. 
Main element: food/plate icon in center. Small running figure in corner. 
Small camera icon. Background: gradient from purple-blue #6366F1 to pink #EC4899. 
Flat design, minimal, recognizable at small sizes.
``` 