# UX Forbedringsplan for Kalorie- og Aktivitetstracker App

## Introduktion

Denne plan beskriver en række konkrete forslag til forbedring af brugeroplevelsen (UX) i kalorie- og aktivitetstracker-appen. Forslagene er baseret på en analyse af appens kernefunktioner og generelle UX-principper. Planen er opdelt i faser for at muliggøre en gradvis implementering.

## Fase 1: Optimering af Kerne-Logningsfunktioner og Navigation

**Mål:** At gøre de mest hyppige handlinger (mad- og aktivitetslogning) så gnidningsfrie som muligt og sikre en intuitiv global navigation.

### Opgave 1.1: Forbedret Global Navigation
*   **Beskrivelse:** Implementer en klar og konsistent global navigation.
*   **Forslag:**
    *   Brug en standard `BottomNavigationBar` i Flutter med 3-5 faste punkter for appens hovedsektioner (f.eks. "Dashboard", "Log Mad/Aktivitet", "Fremskridt", "Profil").
    *   Sørg for tydelig visuel markering af det aktive menupunkt.
    *   Gennemgå og standardiser "tilbage"-knap funktionalitet på tværs af appen for forudsigelig navigation.
*   **Use Case/Princip:** Generel UX (Navigation, Konsistens).

### Opgave 1.2: Optimering af Søgning i Fødevaredatabase (`food_database`)
*   **Beskrivelse:** Gør søgning efter fødevarer hurtigere og mere relevant.
*   **Forslag:**
    *   Implementer "debounce" på søgefeltet for at reducere unødvendige API-kald.
    *   Prioriter søgeresultater: Vis populære varer, tidligere loggede varer, og favoritter øverst.
    *   Overvej "fuzzy search" for at håndtere mindre tastefejl.
    *   Implementer en let tilgængelig stregkodescanner (ikon ved siden af søgefeltet).
    *   Tilføj et "Fandt du ikke hvad du søgte? Opret manuelt" link/knap ved tomme eller utilfredsstillende søgeresultater.
*   **Use Case/Princip:** Daglig Kalorie- og Næringsstofsporing.

### Opgave 1.3: Forenkling af Portionsstørrelser og Enheder (`food_logging`)
*   **Beskrivelse:** Gør det nemmere at angive korrekte portionsstørrelser.
*   **Forslag:**
    *   Tilbyd en liste af almindelige enheder (gram, ml, stk., skive, lille/mellem/stor portion) og gør det let at skifte.
    *   For fødevarer logget tidligere, forudfyld med den senest anvendte portionsstørrelse og enhed.
    *   Gem brugerens foretrukne enhed for specifikke fødevarer, hvis muligt.
*   **Use Case/Princip:** Daglig Kalorie- og Næringsstofsporing.

### Opgave 1.4: Implementering af "Hurtig Logning" (`food_logging`, `activity`)
*   **Beskrivelse:** Reducer antallet af klik for at logge gentagne måltider/aktiviteter.
*   **Forslag:**
    *   "Log Igen" knap for nyligt loggede fødevarer/måltider/aktiviteter, tilgængelig fra en historik-fane eller direkte på dashboardet.
    *   Funktion til at kopiere et helt tidligere måltid (f.eks. "Kopier gårsdagens morgenmad").
    *   Sørg for, at adgang til og logning fra favoritlister (både mad og aktivitet) er maksimalt 1-2 tryk væk fra hovedlogningsskærmen.
*   **Use Case/Princip:** Daglig Kalorie- og Næringsstofsporing, Aktivitetslogning, Effektivitet.

### Opgave 1.5: Forbedret Brugerfeedback under Logning
*   **Beskrivelse:** Giv klar og øjeblikkelig feedback på logningshandlinger.
*   **Forslag:**
    *   Brug korte, ikke-blokerende `SnackBar` eller `Toast` beskeder til at bekræfte handlinger ("Måltid logget!", "Aktivitet tilføjet").
    *   Vis tydelige `CircularProgressIndicator` eller lignende under API-kald (f.eks. ved søgning, gemning af log). Sørg for, at UI ikke fryser.
*   **Use Case/Princip:** Generel UX (Feedback).

## Fase 2: Forbedring af Onboarding, Vægt- og Fremskridtsopfølgning

**Mål:** At gøre opstartsprocessen mere indbydende og give brugerne bedre værktøjer til at spore og forstå deres fremskridt.

### Opgave 2.1: Optimeret Onboarding Flow (`onboarding`, `profile`)
*   **Beskrivelse:** Gør kontooprettelse og den indledende opsætning mere brugervenlig.
*   **Forslag:**
    *   Implementer en visuel step-by-step progressionsindikator (f.eks. "Trin 1 af 4").
    *   Tilføj kontekstuel hjælp (info-ikoner med tooltips/popups) ved felter, der kan være tvetydige (f.eks. "Aktivitetsniveau", forklaring af kalorieberegning).
    *   Forudfyld felter med plausible standarder, som brugeren let kan justere.
    *   Afslut onboarding med en motiverende besked og en klar call-to-action (f.eks. "Log dit første måltid").
*   **Use Case/Princip:** Kontoopsætning og Onboarding.

### Opgave 2.2: Forbedret Vægtlogning og Visualisering (`weight_tracking`, `progress`)
*   **Beskrivelse:** Gør det nemmere at logge vægt og se fremskridt.
*   **Forslag:**
    *   Tilføj en "Log Vægt" genvej på dashboardet eller i en global "plus"-menu.
    *   I `progress`-sektionen:
        *   Implementer en klar linjegraf for vægtudvikling med tydelige akser og datapunkter.
        *   Tillad valg af tidsperioder (uge, måned, 3 måneder, år, alt).
        *   Vis en trendlinje og eventuelt brugerens målvægt på grafen.
        *   Vis seneste loggede vægt og ændring siden sidst.
*   **Use Case/Princip:** Vægtstyring.

### Opgave 2.3: Klarere Fremskridtsvisualisering (`progress`, `dashboard`)
*   **Beskrivelse:** Gør fremskridtsdata mere forståelige og motiverende.
*   **Forslag:**
    *   Brug separate, fokuserede grafer/widgets for nøglemetrikker (f.eks. kalorieindtag vs. mål, makronæringsstoffordeling, gennemsnitligt antal skridt). Undgå overfyldte diagrammer.
    *   Under eller ved siden af grafer, tilføj korte tekstuelle opsummeringer eller "indsigter" (f.eks. "Du har ramt dit kaloriemål 5 ud af 7 dage denne uge.").
    *   Sørg for, at `KSizes` bruges konsekvent til at skabe visuel balance og læsbarhed i grafer og tabeller.
*   **Use Case/Princip:** Fremskridtsovervågning.

## Fase 3: Finpudsning af Detaljer og Avancerede Funktioner

**Mål:** At forbedre den generelle "polish" af appen, håndtere fejl bedre og optimere mindre hyppigt brugte, men stadig vigtige funktioner.

### Opgave 3.1: Manuel Fødevareoprettelse (`food_logging`)
*   **Beskrivelse:** Gør processen for manuel oprettelse af fødevarer mere intuitiv.
*   **Forslag:**
    *   Design en simpel og overskuelig formular.
    *   Fokuser på de mest nødvendige felter (navn, kalorier, serveringsstørrelse).
    *   Gør makronæringsstoffer (protein, kulhydrat, fedt) lette at indtaste.
    *   Avancerede felter (vitaminer, mineraler) kan være valgfri/kollapsede under en "Detaljer" sektion.
    *   Mulighed for at gemme den manuelt oprettede fødevare til "Mine Fødevarer" eller favoritter.
*   **Use Case/Princip:** Daglig Kalorie- og Næringsstofsporing.

### Opgave 3.2: Forbedret Aktivitetslogning (`activity`)
*   **Beskrivelse:** Gør det nemmere at finde og logge forskellige typer aktiviteter.
*   **Forslag:**
    *   Implementer tydelig kategorisering af aktiviteter (f.eks. Løb, Cykling, Styrketræning, Hjemmetræning).
    *   Forbedr søgefunktionen for aktiviteter.
    *   For aktiviteter hvor det er relevant, tilbyd simple intensitetsniveauer (let, moderat, hård) der justerer kalorieforbrændingen.
    *   Tillad brugere at gemme brugerdefinerede aktiviteter, som ikke findes i databasen.
*   **Use Case/Princip:** Aktivitetslogning.

### Opgave 3.3: Konsistent Fejlhåndtering og Validering
*   **Beskrivelse:** Sørg for informative og brugervenlige fejlmeddelelser og inputvalidering.
*   **Forslag:**
    *   Standardiser udseendet og placeringen af fejlmeddelelser (f.eks. under inputfelter).
    *   Skriv fejlmeddelelser på et klart, menneskeligt sprog. Undgå teknisk jargon.
    *   Hvor muligt, foreslå en løsning eller næste skridt.
    *   Implementer realtidsvalidering på inputfelter, hvor det er relevant (f.eks. format for e-mail, numeriske værdier for kalorier).
    *   For netværksfejl, inkluder altid en "Prøv igen" knap.
*   **Use Case/Princip:** Generel UX (Fejlhåndtering).

### Opgave 3.4: Gennemgang af Profiltilpasning (`profile`)
*   **Beskrivelse:** Sikre at brugeren let kan finde og redigere personlige oplysninger og mål.
*   **Forslag:**
    *   Organiser profilindstillinger logisk i sektioner.
    *   Sørg for, at det er tydeligt, hvordan ændringer gemmes.
    *   Bekræft ændringer med en `SnackBar` eller lignende.
*   **Use Case/Princip:** Profiltilpasning.

### Opgave 3.5: Adgang til Information og Support (`info`)
*   **Beskrivelse:** Gør det nemt for brugere at finde hjælp og information.
*   **Forslag:**
    *   Opret en tydelig "Hjælp & Support" sektion i appen.
    *   Inkluder FAQ, guides til kernefunktioner, og evt. kontaktinformation.
    *   Sørg for, at indholdet er let at søge i.
*   **Use Case/Princip:** Adgang til Information og Support.

## Implementeringsnoter

*   **Prioritering:** Følg faserne som angivet, da de bygger ovenpå hinanden. Inden for hver fase kan opgaver prioriteres yderligere baseret på estimeret impact og udviklingstid.
*   **Iterativ Tilgang:** Implementer ændringer i mindre bidder. Test internt og/eller med en lille brugergruppe før fuld udrulning.
*   **Indsaml Feedback:** Efter implementering af forbedringer, indsaml aktivt brugerfeedback (f.eks. via in-app surveys, anmeldelser) for at vurdere effekten og identificere yderligere justeringsbehov.
*   **Design System Konsistens:** Fortsat håndhævelse af `KSizes` og andre design system elementer er afgørende for et professionelt og konsistent look and feel.

Denne plan tjener som en guide. Den kan og bør justeres baseret på ny indsigt og brugerfeedback undervejs. 