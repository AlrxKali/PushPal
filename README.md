# PushPal

## Gym Accountability Buddy App 💪

The Gym Accountability Buddy App aims to connect users with compatible fitness partners in real time based on location, goals, and availability. It includes progress tracking, challenge features, and social support to keep motivation high.

## Development Phases

### Phase 0: Project Setup & Foundation
*   **Objective:** Initialize the Flutter project, ensure Firebase is correctly integrated, set up basic project structure, navigation, and a simple theme.
*   **Key Tasks:**
    *   Verify Flutter project setup.
    *   Confirm Firebase project integration (Auth, Firestore, Storage, Cloud Messaging).
    *   Establish a clean folder structure (e.g., for screens, widgets, services, models).
    *   Implement basic navigation (e.g., using `Navigator 2.0` or a package like `go_router`).
    *   Define a simple color scheme and typography for the app.

### Phase 1: User Authentication & Profile Management
*   **Objective:** Allow users to sign up, log in, and manage their core profile information.
*   **Key Tasks:**
    *   Design and implement UI for Sign Up and Login screens.
    *   Integrate Firebase Authentication for email/password login (and potentially social logins later).
    *   Create a User model (name, age, gender, location, fitness goal, preferred workout type, availability).
    *   Develop a Profile screen where users can create and edit their information.
    *   Store and retrieve user profile data from Firestore.

### Phase 2: Landing Page / Pre-launch Interest Gauging
*   **Objective:** Create a simple page to explain the app (focused on the initial niche) and collect interest before a full launch.
*   **Key Tasks:**
    *   Design a simple landing page UI (can be a screen within the app for MVP if a separate web page is too much initially).
    *   Clearly state the app's value proposition for the chosen niche.
    *   Implement a waitlist signup (e.g., collecting emails and storing them in Firestore or using a simple backend function).

### Phase 3: Core Buddy Matching Engine
*   **Objective:** Implement the core functionality of matching users based on their profiles and preferences.
*   **Key Tasks:**
    *   Define the matching logic (initially simple filters: location proximity, workout type, availability).
    *   Design and implement a UI to display potential buddies (e.g., a list view with filters).
    *   Fetch and display users from Firestore based on search/filter criteria.
    *   Implement a "Connect" or "Request Contact" feature.
        *   For MVP, this could reveal an email (with consent) or enable a very basic in-app messaging thread using Firestore.

### Phase 4: Simple Progress Tracking & Accountability
*   **Objective:** Introduce basic features to encourage user commitment and allow buddies to share progress.
*   **Key Tasks:**
    *   Implement a daily check-in feature ("Did you work out today?").
    *   Allow optional data logging (e.g., workout notes, weight). Photo uploads can use Firebase Storage.
    *   Store this progress data in Firestore.
    *   Make progress visible to connected buddies (with appropriate permissions).

### Phase 5: Challenges & Reminders
*   **Objective:** Increase engagement and stickiness through simple challenges and notifications.
*   **Key Tasks:**
    *   Concept and implement simple weekly challenges (e.g., "Complete 3 workouts this week").
    *   Integrate Firebase Cloud Messaging (FCM) for:
        *   Workout reminders.
        *   Nudges from buddies (e.g., "X just checked in their workout!").
        *   Challenge notifications.

### Phase 6: Analytics, Feedback & Iteration
*   **Objective:** Gather data on app usage and user feedback to inform future development.
*   **Key Tasks:**
    *   Integrate Firebase Analytics to track key user actions (signups, profile completion, matches, check-ins).
    *   Implement a simple in-app feedback mechanism (optional for first MVP, but useful).
    *   Review analytics and feedback to plan for the next iteration and potential expansion beyond the initial niche.

# Key Information/Status:
* A summary of their primary fitness goal or preferred workout types.
* If they have active "Pals" or connections, a quick way to see them (though this is future functionality, we can plan the space).


# VERY IMPORTANT FOR PRODUCTION
Create cors.json file:
Create a file named cors.json on your computer with this content:
```
    [
      {
        "origin": ["*"],
        "method": ["GET"],
        "maxAgeSeconds": 3600
      }
    ]
```
Apply to user_profile...
(For production, replace "*" with your app's actual domains: ["https://YOUR_PROJECT_ID.web.app", "https://YOUR_PROJECT_ID.firebaseapp.com"] and any custom domains).