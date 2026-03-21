# feat/authentication

## Summary

This branch implements the full authentication, onboarding, and post-auth home experience for the Roomora iOS app, building on the design system foundation from `main`.

### Authentication

Sign up flow with role selection (student or landlord), first and last name, email, password with real-time strength indicator, optional phone number, and 6-digit email verification via OTP. Sign in with email and password, loading states, and inline error handling. Session management through a `UserSession` observable that syncs with the Rails backend and persists auth state using Clerk session tokens.

### Onboarding — Students (3 Steps)

1. **Build Profile** — Photo picker, university text field, major dropdown with 30 common options, birth year and graduation year pickers (1970 to current+5), bio with a 5-character minimum hint, and selectable hobby chips. Emoji prefixes are stripped before sending hobbies to the backend.
2. **Roommate Situation** — Card-based selection between "I have a place" and "I need a place". This choice determines what step 3 shows.
3. **Roommate Preferences** (if user has a place) — Spots available stepper, move-in month, gender preference (no preference / same as me / women only / men only), sleep schedule (early bird / night owl / no preference), cleanliness level, lifestyle tags, and requirement tags. All values stored as integers or text arrays.
   **Listing Preferences** (if user needs a place) — Budget chips, 2x2 property type grid, move-in date picker, lease length chips, max distance chips, amenity grid, and preference rows with checkmarks.

### Onboarding — Landlords (2 Steps)

1. **Build Profile** — Same as student but without university, major, and graduation year fields. Stored in a separate `landlord_profiles` table.
2. **New Listing** — Cover photo picker, property title, monthly rent, security deposit, property type chips (Shared room, Studio, 1 bedroom, 2 bedrooms, 3+ bedrooms), lease length dropdown, available-from date picker, amenity flow layout (WiFi, Laundry, Parking, AC, Gym, Pool, Balcony, Furnished), non-negotiable rules flow layout (No smoking, No parties, No pets, etc.), and description with a minimum character counter. The listing is created via `POST /listings` when the landlord completes onboarding.

### Onboarding Completion

A celebration screen with a confetti particle animation and a personalized welcome message, followed by a transition into the home screen.

### Student Home Screen

Tabbed interface switching between Roommate and Housing views. Features a greeting header, featured listing cards with images, nearby property cards with distance and price, and a map view powered by `ListingsMapView`. Bottom navigation with five tabs: Discover, Map, Likes, Messages, and Profile.

### Landlord Home Screen

Stats row displaying listing count (fetched from the API), with placeholder values for views, applications, and rating. A tab picker switches between My Listings and Applications. Listing cards are fetched from `GET /api/v1/listings/mine` on view appear and display the title, status badge (Active, Pending, or Draft), property type, and monthly rent. Tapping a listing opens a detail sheet with a gradient header, status pill, rent and deposit breakdown, a property details grid (type, lease length, available date), amenity tags, house rule tags, description, and location. The Applications tab shows tenant cards with university, move-in date, and compatibility percentage (currently using mock data). An "Add new listing" button with a dashed border is displayed above the listings.

### API Integration

A centralized `APIClient` handles all HTTP communication with JWT bearer auth via Clerk session tokens, `async/await`, and automatic `snake_case` to `camelCase` key decoding.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/sync` | Create or sync user on sign-up |
| GET | `/profile` | Fetch full user profile |
| PATCH | `/profile` | Update user fields (e.g. mark as onboarded) |
| PATCH | `/profile/student` | Update student profile fields |
| PATCH | `/profile/landlord` | Update landlord profile fields |
| PATCH | `/profile/lifestyle` | Update roommate and lifestyle preferences |
| PATCH | `/profile/listing_preferences` | Update listing search preferences |
| POST | `/listings` | Create a new property listing |
| GET | `/listings/mine` | Fetch the current user's listings |

### Navigation

`AppRouter` is an observable class managing a `NavigationStack` path, modal sheet presentation (sign-in), and popup overlays. `ContentView` acts as the root state machine: unauthenticated users see the landing page, authenticated but loading users see a spinner with a retry option, authenticated but not onboarded users see the onboarding flow, and fully onboarded users see the role-appropriate home screen.

### New Components

| Component | Description |
|-----------|-------------|
| AppTextField | Text field with icon, label, placeholder, secure mode, and multiline support |
| ConfettiView | Particle animation used on onboarding completion |
| ErrorMessage | Inline error text display |
| FlowLayout | Dynamic wrapping layout for tag and chip groups |
| HintBanner | Contextual hint banner with attributed string support |
| ListingDetailSheet | Full listing detail popup with gradient header and formatted sections |
| PasswordStrengthBar | Visual indicator of password strength |
| PhoneField | Phone number input with country code selector |
| PreferenceSection | Reusable labeled preference row |
| ProfileAvatar | User avatar circle with Clerk profile image |
| PulseLoader | Animated loading indicator |
| RolePicker | Student and landlord role selection cards |

---

## Stats

- 62 files changed
- Approximately 5,350 lines added
- 26 commits
