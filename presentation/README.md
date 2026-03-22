# GitOps w praktyce - Prezentacja

Prezentacja o automatyzacji wdrożeń w Kubernetes z Argo CD.

## Uruchamianie lokalnie

```bash
npm install
npm run dev
```

Prezentacja będzie dostępna pod adresem: http://localhost:5173

## Uruchamianie w kontenerze Docker

### Metoda 1: Docker Compose (zalecana)

```bash
docker-compose up
```

### Metoda 2: Docker build i run

Build obrazu:
```bash
docker build -t gitops-presentation .
```

Uruchomienie kontenera:
```bash
docker run -p 5173:5173 gitops-presentation
```

Prezentacja będzie dostępna pod adresem: http://localhost:5173

## Eksport do PDF

### Metoda 1: Przez przeglądarkę (zalecana)

1. Uruchom prezentację lokalnie lub w kontenerze
2. Otwórz w przeglądarce URL: **http://localhost:5173/?print-pdf**
3. Otwórz narzędzia developerskie (F12) i ustaw responsywny widok na szerokość 1920px
4. Zaczekaj aż wszystkie slajdy się załadują
5. Użyj funkcji drukowania przeglądarki (Ctrl/Cmd + P)
6. Wybierz "Zapisz jako PDF"
7. W opcjach drukowania ustaw:
   - Marginesy: "Brak"
   - Tło: "Włączone" (Background graphics)
8. Zapisz PDF

### Metoda 2: Automatyczna (wymaga decktape)

Zainstaluj decktape globalnie:
```bash
npm install -g decktape
```

Uruchom serwer w jednym terminalu:
```bash
npm run dev
```

W drugim terminalu wykonaj eksport:
```bash
decktape reveal http://localhost:5173 prezentacja-gitops.pdf
```

## Build produkcyjny

```bash
npm run build
```

Zbudowane pliki znajdą się w folderze `dist/`.

## Technologie

- [reveal.js](https://revealjs.com/) - framework do prezentacji HTML
- [Vite](https://vitejs.dev/) - build tool
- Docker - konteneryzacja

## Autor

**Mateusz Wocka**
- LinkedIn: [linkedin.com/in/mateusz-wocka](https://www.linkedin.com/in/mateusz-wocka-24ba4b188/)

## Licencja

- reveal.js: MIT License © Hakim El Hattab
- Treść prezentacji: © 2026 Mateusz Wocka
