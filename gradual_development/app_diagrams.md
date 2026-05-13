# Movie Watchlist App - Complete Diagram Set

## 1) Use Case Diagram

```mermaid
flowchart LR
  User((User))
  TMDB[(TMDB API)]
  FirebaseAuth[(Firebase Auth)]
  Firestore[(Firestore)]
  FCM[(Firebase Cloud Messaging)]

  subgraph App[Movie Watchlist App]
    UC1([Sign Up])
    UC2([Login])
    UC3([Reset Password])
    UC4([Complete Onboarding])
    UC5([View Home Trending])
    UC6([Search Movies/TV])
    UC7([Filter Search by Genre/Year/Rating])
    UC8([Browse by Genre])
    UC9([Open Movie/TV Details])
    UC10([Play Trailer])
    UC11([Add to Watchlist])
    UC12([Remove from Watchlist])
    UC13([Mark as Watched])
    UC14([Remove from Watched])
    UC15([Rate Watched Item])
    UC16([View Notifications])
    UC17([View Profile])
    UC18([Change Password])
    UC19([Open Deep Link Movie by ID])
  end

  User --> UC1
  User --> UC2
  User --> UC3
  User --> UC4
  User --> UC5
  User --> UC6
  User --> UC7
  User --> UC8
  User --> UC9
  User --> UC10
  User --> UC11
  User --> UC12
  User --> UC13
  User --> UC14
  User --> UC15
  User --> UC16
  User --> UC17
  User --> UC18
  User --> UC19

  UC1 --> FirebaseAuth
  UC2 --> FirebaseAuth
  UC3 --> FirebaseAuth
  UC18 --> FirebaseAuth

  UC5 --> TMDB
  UC6 --> TMDB
  UC7 --> TMDB
  UC8 --> TMDB
  UC9 --> TMDB
  UC10 --> TMDB
  UC19 --> TMDB

  UC11 --> Firestore
  UC12 --> Firestore
  UC13 --> Firestore
  UC14 --> Firestore
  UC15 --> Firestore

  UC16 --> FCM
```

## 2) Class Diagram

```mermaid
classDiagram
  class AuthRepository {
    <<interface>>
    +Stream~User?~ authStateChanges
    +signInWithEmailAndPassword(email, password) User?
    +signUpWithEmailAndPassword(email, password) User?
    +signOut() void
  }

  class FirebaseAuthRepository
  AuthRepository <|.. FirebaseAuthRepository

  class TmdbRemoteDataSource {
    +searchMovies(query, filters, page) MoviePage
    +getTrending(page) MoviePage
    +getGenres() List~Genre~
  }

  class MovieRepository {
    <<interface>>
    +searchMovies(query, filters, page) Result~MoviePage~
    +getTrending(page) Result~MoviePage~
    +getGenres() Result~List~Genre~~
  }

  class MovieRepositoryImpl
  MovieRepository <|.. MovieRepositoryImpl
  MovieRepositoryImpl --> TmdbRemoteDataSource

  class GetTrendingMoviesUseCase {
    +call(page) Result~MoviePage~
  }
  class SearchMoviesUseCase {
    +call(query, filters, page) Result~MoviePage~
  }
  class GetMovieGenresUseCase {
    +call() Result~List~Genre~~
  }

  GetTrendingMoviesUseCase --> MovieRepository
  SearchMoviesUseCase --> MovieRepository
  GetMovieGenresUseCase --> MovieRepository

  class WatchlistRepository {
    <<interface>>
    +getWatchlist() Stream~List~WatchlistItem~~
    +add(item) void
    +remove(item) void
  }
  class WatchlistRepositoryImpl
  WatchlistRepository <|.. WatchlistRepositoryImpl

  class FirestoreWatchlistDataSource
  WatchlistRepositoryImpl --> FirestoreWatchlistDataSource

  class WatchlistService {
    +getWatchlistStream() Stream~List~WatchlistItem~~
    +addItem(item) void
    +removeItem(item) void
    +isInWatchlist(item) bool
  }

  class WatchedService {
    +getWatchedStream() Stream~List~WatchlistItem~~
    +addItem(item) void
    +removeItem(item) void
    +setRating(item, rating) void
    +getRating(item) int?
  }

  class NotificationService {
    +initialise(navigatorKey) void
    +addNotification(title, message) void
    +markAsRead(id) void
  }

  class Movie {
    +int id
    +String title
    +String overview
    +double voteAverage
    +List~int~ genreIds
  }
  class TvShow {
    +int id
    +String name
    +String overview
    +double voteAverage
    +List~int~ genreIds
  }
  class Genre {
    +int id
    +String name
  }
  class MovieFilters {
    +int? genreId
    +int? year
    +double? minimumRating
  }
  class MoviePage {
    +List~Movie~ movies
    +int page
    +int totalPages
  }
  class WatchlistItem {
    +int id
    +String type
    +Map data
    +String docId
  }
```

## 3) Sequence Diagrams (10)

### 3.1 Login Flow
```mermaid
sequenceDiagram
  actor U as User
  participant LS as LoginScreen
  participant AP as AuthProvider
  participant AR as FirebaseAuthRepository
  participant FA as FirebaseAuth
  participant R as AppRouter

  U->>LS: Enter email/password + tap Login
  LS->>AP: signIn(email, password)
  AP->>AR: signInWithEmailAndPassword()
  AR->>FA: signInWithEmailAndPassword()
  FA-->>AR: UserCredential
  AR-->>AP: User
  AP-->>LS: Success state
  LS->>R: navigate /home
```

### 3.2 Signup Flow
```mermaid
sequenceDiagram
  actor U as User
  participant SS as SignUpScreen
  participant AP as AuthProvider
  participant AR as FirebaseAuthRepository
  participant FA as FirebaseAuth

  U->>SS: Submit registration form
  SS->>AP: signUp(email, password)
  AP->>AR: signUpWithEmailAndPassword()
  AR->>FA: createUserWithEmailAndPassword()
  FA-->>AR: UserCredential
  AR-->>AP: User
  AP-->>SS: Success / error state
```

### 3.3 Load Home Trending
```mermaid
sequenceDiagram
  actor U as User
  participant HS as HomeScreen
  participant UC as GetTrendingMoviesUseCase
  participant MR as MovieRepositoryImpl
  participant DS as TmdbRemoteDataSource
  participant TMDB as TMDB API

  U->>HS: Open Home tab
  HS->>UC: call(page)
  UC->>MR: getTrending(page)
  MR->>DS: getTrending(page)
  DS->>TMDB: GET /trending/movie/day
  TMDB-->>DS: JSON results
  DS-->>MR: MoviePage
  MR-->>UC: Result<MoviePage>
  UC-->>HS: Movie list
  HS-->>U: Render carousel/cards
```

### 3.4 Search with Filters
```mermaid
sequenceDiagram
  actor U as User
  participant MSS as MovieSearchScreen
  participant MSN as MovieSearchNotifier
  participant UC as SearchMoviesUseCase
  participant MR as MovieRepositoryImpl
  participant DS as TmdbRemoteDataSource
  participant TMDB as TMDB API

  U->>MSS: Enter query + select filters
  MSS->>MSN: search(query, filters, page)
  MSN->>UC: call(query, filters, page)
  UC->>MR: searchMovies(...)
  MR->>DS: searchMovies(...)
  DS->>TMDB: GET /search/movie or /discover/movie
  TMDB-->>DS: JSON page
  DS-->>MR: MoviePage
  MR-->>UC: Result<MoviePage>
  UC-->>MSN: Result
  MSN-->>MSS: New state
```

### 3.5 Open Details from Search/Home
```mermaid
sequenceDiagram
  actor U as User
  participant UI as Card/List UI
  participant R as GoRouter
  participant DS as DetailScreen
  participant TMDB as TMDB API

  U->>UI: Tap movie/tv card
  UI->>R: go('/details', extra: item)
  R->>DS: Build DetailScreen(item)
  DS->>TMDB: Fetch enriched details (videos, credits, etc)
  TMDB-->>DS: Detail payload
  DS-->>U: Display overview, cast, trailer, watch providers
```

### 3.6 Add to Watchlist
```mermaid
sequenceDiagram
  actor U as User
  participant WB as WatchlistButton
  participant WS as WatchlistService
  participant FS as Firestore

  U->>WB: Tap bookmark add
  WB->>WS: addItem(movieOrTv)
  WS->>FS: set users/{uid}/watchlist/{type_id}
  FS-->>WS: write success
  WS-->>WB: done
  WB-->>U: UI state active + notification
```

### 3.7 Remove from Watchlist
```mermaid
sequenceDiagram
  actor U as User
  participant WL as WatchlistScreen
  participant WS as WatchlistService
  participant FS as Firestore

  U->>WL: Tap remove
  WL->>WS: removeItem(item)
  WS->>FS: delete users/{uid}/watchlist/{type_id}
  FS-->>WS: delete success
  WS-->>WL: Stream updates
  WL-->>U: Item removed from list
```

### 3.8 Mark Item as Watched + Rate
```mermaid
sequenceDiagram
  actor U as User
  participant WB as WatchedButton
  participant WDS as WatchedService
  participant FS as Firestore

  U->>WB: Mark as watched
  WB->>WDS: addItem(item)
  WDS->>FS: set users/{uid}/watched/{type_id}
  FS-->>WDS: success
  U->>WB: Set rating (1-5)
  WB->>WDS: setRating(item, rating)
  WDS->>FS: update user_rating
  FS-->>WDS: success
```

### 3.9 Notification Arrival and Open
```mermaid
sequenceDiagram
  participant FCM as Firebase Messaging
  participant NS as NotificationService
  participant NAV as Navigator
  actor U as User

  FCM-->>NS: onMessage / onMessageOpenedApp
  NS->>NS: addNotification(title, body)
  U->>NAV: Open notifications or tap push
  NS->>NAV: navigate to movie route or notifications
```

### 3.10 Deep Link Movie Route
```mermaid
sequenceDiagram
  actor U as User
  participant R as GoRouter
  participant DL as DeepLinkMovieLoader
  participant TMDB as TMDB API
  participant DS as DetailScreen

  U->>R: Open /movie/:id
  R->>DL: Build loader(movieId)
  DL->>TMDB: Fetch movie by id
  TMDB-->>DL: Movie payload
  DL->>DS: Navigate/compose with loaded movie
  DS-->>U: Show movie details
```

## 4) Activity Diagram (End-to-End User Journey)

```mermaid
flowchart TD
  A([Start App]) --> B{Splash done + auth state ready?}
  B -- No --> B
  B -- Yes --> C{Authenticated?}
  C -- No --> D{Onboarding completed?}
  D -- No --> E[Show Onboarding]
  E --> F[Go to Login/Signup]
  D -- Yes --> F
  F --> G[Authenticate]
  G --> H[Home]
  C -- Yes --> H

  H --> I[Browse Trending]
  H --> J[Search/Filter]
  H --> K[Open Details]
  K --> L{User action}
  L --> M[Add/Remove Watchlist]
  L --> N[Mark Watched]
  N --> O[Set/Clear Rating]
  H --> P[Open Watchlist]
  H --> Q[Open Profile/About]
  H --> R[Open Notifications]
  M --> S([End/Continue Session])
  O --> S
  P --> S
  Q --> S
  R --> S
  I --> S
  J --> S
```

## 5) Data Flow Diagram (Logical DFD - Level 1)

```mermaid
flowchart LR
  U((User))
  P1[Auth Process]
  P2[Discovery/Search Process]
  P3[Watchlist Process]
  P4[Watched & Rating Process]
  P5[Notification Process]

  D1[(Firebase Auth)]
  D2[(TMDB API)]
  D3[(Firestore users/{uid}/watchlist)]
  D4[(Firestore users/{uid}/watched)]
  D5[(In-memory Notifications)]
  D6[(FCM)]

  U -->|Credentials| P1
  P1 -->|Login/Signup/Reset| D1
  D1 -->|Auth State| P1
  P1 -->|Session| U

  U -->|Query/filters/navigation| P2
  P2 -->|Read movies/tv/genres| D2
  D2 -->|Results/details| P2
  P2 -->|Rendered content| U

  U -->|Add/remove watchlist| P3
  P3 -->|Write/read stream| D3
  D3 -->|Watchlist items| P3
  P3 -->|List + badge| U

  U -->|Mark watched/rate| P4
  P4 -->|Write/read stream| D4
  D4 -->|Watched items + ratings| P4
  P4 -->|Watched UI| U

  D6 -->|Push message| P5
  U -->|Open/mark/remove notifications| P5
  P5 -->|Store/read| D5
  P5 -->|Notification list + deep link nav| U
```

## 6) ER Diagram (Firestore-Centric Data Model)

```mermaid
erDiagram
  USERS ||--o{ WATCHLIST_ITEMS : has
  USERS ||--o{ WATCHED_ITEMS : has

  USERS {
    string uid PK
    string email
    datetime created_at
  }

  WATCHLIST_ITEMS {
    string doc_id PK
    string user_uid FK
    int tmdb_id
    string type
    string title_or_name
    string poster_path
    string backdrop_path
    string release_or_air_date
    float vote_average
    int vote_count
    string overview
    string original_language
    float popularity
    array genre_ids
    datetime saved_at
  }

  WATCHED_ITEMS {
    string doc_id PK
    string user_uid FK
    int tmdb_id
    string type
    string title_or_name
    string poster_path
    string backdrop_path
    string release_or_air_date
    float vote_average
    int vote_count
    string overview
    string original_language
    float popularity
    array genre_ids
    int user_rating
    datetime watched_at
  }
```

## 7) Notes on Coverage

- Diagram set is aligned to current Flutter architecture and features present in `lib/`.
- Sequence diagrams intentionally cover the major interaction paths end to end.
- If you want, the next step can be generating a PlantUML version and exporting PNG/SVG files for reports.

## 8) Textual Version of Each Diagram

### 8.1 Textual Use Case Model

Actor:
- User

External systems:
- Firebase Auth
- TMDB API
- Firestore
- Firebase Cloud Messaging (FCM)

Use cases:
1. Sign Up: user creates account via Firebase Auth.
2. Login: user signs in via Firebase Auth.
3. Reset Password: user requests reset using Firebase Auth flow.
4. Complete Onboarding: first-time user completes onboarding screens.
5. View Home Trending: app fetches trending movies from TMDB.
6. Search Movies/TV: user searches content using TMDB endpoints.
7. Filter Search by Genre/Year/Rating: user applies filters; app uses TMDB discover/search query params.
8. Browse by Genre: user opens a genre and sees matching content.
9. Open Movie/TV Details: app loads detailed metadata from TMDB.
10. Play Trailer: app uses trailer data loaded from TMDB detail responses.
11. Add to Watchlist: app stores selected item in Firestore under user watchlist.
12. Remove from Watchlist: app deletes item from Firestore watchlist.
13. Mark as Watched: app stores item in Firestore watched collection.
14. Remove from Watched: app deletes watched item from Firestore.
15. Rate Watched Item: app writes `user_rating` to watched document.
16. View Notifications: user views local/push notification entries.
17. View Profile: user opens profile tab/screen.
18. Change Password: user changes password through auth flow.
19. Open Deep Link Movie by ID: route `/movie/:id` resolves item and opens details.

### 8.2 Textual Class Model

Authentication layer:
- `AuthRepository` defines auth contract: auth state stream, sign in, sign up, sign out.
- `FirebaseAuthRepository` implements that contract using Firebase Authentication SDK.

Movies/discovery layer:
- `TmdbRemoteDataSource` handles remote HTTP calls to TMDB (`searchMovies`, `getTrending`, `getGenres`).
- `MovieRepository` defines domain-facing repository interface.
- `MovieRepositoryImpl` delegates to `TmdbRemoteDataSource` and maps errors/results.
- Use cases:
  - `GetTrendingMoviesUseCase`
  - `SearchMoviesUseCase`
  - `GetMovieGenresUseCase`
  These depend on `MovieRepository`.

Watchlist layer:
- `WatchlistRepository` defines domain contract for watchlist stream and mutations.
- `WatchlistRepositoryImpl` implements contract using `FirestoreWatchlistDataSource`.
- `WatchlistService` provides practical watchlist operations used by UI/providers.

Watched layer:
- `WatchedService` mirrors watchlist behavior but persists in watched collection and manages ratings.

Notifications layer:
- `NotificationService` initializes FCM listeners, stores in-memory notifications, and handles navigation on push taps.

Core entities/value objects:
- `Movie`, `TvShow`, `Genre`, `MovieFilters`, `MoviePage`, `WatchlistItem`.

### 8.3 Textual Sequence Model (10 Flows)

1. Login Flow:
- User submits credentials on `LoginScreen`.
- UI asks auth provider to sign in.
- Provider calls `FirebaseAuthRepository`.
- Repository calls Firebase Auth SDK.
- On success, user object returns and router redirects to `/home`.

2. Signup Flow:
- User submits registration on `SignUpScreen`.
- Provider calls `signUpWithEmailAndPassword`.
- Firebase creates account and returns user.
- UI receives success state (or error state).

3. Load Home Trending:
- User opens Home tab.
- `HomeScreen` triggers `GetTrendingMoviesUseCase`.
- Use case calls repository, repository calls TMDB data source.
- TMDB returns JSON list; app maps to `MoviePage`.
- UI renders cards/carousel.

4. Search with Filters:
- User enters query and filters.
- Screen/notifier triggers `SearchMoviesUseCase`.
- Repository/data source call TMDB search or discover endpoint.
- Results map to domain model and update screen state.

5. Open Details from Search/Home:
- User taps item card.
- Router navigates to `/details` with selected item.
- Details screen fetches enriched details from TMDB.
- UI renders overview, cast, trailer, and watch-provider info.

6. Add to Watchlist:
- User taps watchlist button.
- `WatchlistService.addItem` creates `type_id` doc id.
- Firestore writes `users/{uid}/watchlist/{type_id}`.
- UI toggles state and shows feedback.

7. Remove from Watchlist:
- User removes item from watchlist screen.
- Service deletes Firestore document.
- Stream refreshes and list updates automatically.

8. Mark as Watched + Rate:
- User marks item watched via `WatchedService.addItem`.
- Firestore saves item in `users/{uid}/watched/{type_id}`.
- User sets rating; service updates `user_rating`.

9. Notification Arrival and Open:
- FCM emits message to `NotificationService`.
- Service stores notification in in-memory list.
- On tap/open, app navigates to target movie route or notifications screen.

10. Deep Link Movie Route:
- User opens `/movie/:id`.
- Router builds `DeepLinkMovieLoader`.
- Loader fetches item from TMDB by id.
- App opens detail view with loaded data.

### 8.4 Textual Activity Model (End-to-End Journey)

1. App starts and shows splash.
2. App waits until splash timer and auth state are both ready.
3. Decision: authenticated or not.
4. If not authenticated, decision: onboarding complete or not.
5. If onboarding not complete, show onboarding then move to login/signup.
6. User authenticates and enters Home.
7. From Home, user can browse trending, search/filter, open details, open watchlist, open profile/about, and open notifications.
8. In details, user can add/remove watchlist and mark/rate watched.
9. Session can continue with repeated navigation/actions or end.

### 8.5 Textual Data Flow Model (DFD Level 1)

External entity:
- User

Processes:
- `P1` Auth Process
- `P2` Discovery/Search Process
- `P3` Watchlist Process
- `P4` Watched & Rating Process
- `P5` Notification Process

Data stores/systems:
- `D1` Firebase Auth
- `D2` TMDB API
- `D3` Firestore watchlist collection
- `D4` Firestore watched collection
- `D5` In-memory notifications store
- `D6` FCM

Main flows:
1. User credentials enter `P1`; `P1` exchanges auth operations with `D1`; session state returns to user.
2. User queries/filters enter `P2`; `P2` reads from `D2`; content returns to user.
3. User watchlist actions enter `P3`; `P3` writes/reads `D3`; updated list/badge returns to user.
4. User watched/rating actions enter `P4`; `P4` writes/reads `D4`; updated watched list returns to user.
5. Push messages arrive from `D6` into `P5`; user notification actions also enter `P5`; `P5` reads/writes `D5`; notification UI/deeplink navigation returns to user.

### 8.6 Textual ER Model

Entity: `USERS`
- Primary key: `uid`
- Attributes: `email`, `created_at`

Entity: `WATCHLIST_ITEMS`
- Primary key: `doc_id` (format typically `movie_<id>` or `tv_<id>`)
- Foreign key: `user_uid` references `USERS.uid`
- Main attributes: content id/type/title/media metadata, genre ids, saved timestamp

Entity: `WATCHED_ITEMS`
- Primary key: `doc_id`
- Foreign key: `user_uid` references `USERS.uid`
- Main attributes: same base metadata as watchlist plus `user_rating` and watched timestamp

Relationships:
1. One user to many watchlist items (`USERS 1:N WATCHLIST_ITEMS`).
2. One user to many watched items (`USERS 1:N WATCHED_ITEMS`).

Business rules:
1. A watchlist item belongs to exactly one user.
2. A watched item belongs to exactly one user.
3. `user_rating` is optional until user rates the watched item.
