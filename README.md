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

# Enhancements to Existing Fields/Concepts:
1. **Fitness Goal Granularity:** 
    * Instead of just "Weight Loss," maybe "Postpartum Recovery," "Gentle Exercise," "Low-Impact Fitness," "Active Aging," "Prenatal Fitness."
    * Consider allowing users to type in a custom goal if none of the predefined options fit.
2. **Workout Type Granularity/New Categories:**
    * **Low-Impact:** "Walking," "Swimming," "Water Aerobics," "Tai Chi," "Chair Yoga," "Pilates (modified)."
    * **Specialized:** "Prenatal Yoga," "Postnatal Strength Training," "Senior Fitness Class."
    * **Social/Relaxation:** "Stretching & Mobility," "Meditation Group," "Social Walking Group."
3. **Availability Details:**
    * **Duration Preference:** "30 mins," "45 mins," "1 hour," "1 hour+." (Useful for those with limited time or energy).
    * **Intensity Preference:** "Low," "Moderate," "High" (could be per workout type or a general preference).

# New Profile Fields:
1. **Life Stage/Condition (Optional & Private by Default):**
    * lifeStage: (Multi-select or single select, strictly optional)
        * "Expecting a baby"
        * "New parent (postpartum)"
        * "Senior (65+)"
        * "Managing a chronic condition" (very general, users wouldn't specify the condition unless they choose to in a free-text field)
        * "Recovering from injury"
        * "None of these / Prefer not to say"
    * Consideration: How this data is used for matching needs to be very clear to the user, emphasizing privacy. It could be used to find others in similar situations or to filter for activities suitable for these stages.
2. **Support Needs/Preferences (Optional):**
    * supportPreferences: (Multi-select, optional)
        * "Looking for motivation"
        * "Need a gentle pace"
        * "Child-friendly activities" (if applicable, e.g., stroller walks)
        * "Accessible locations" (e.g., for mobility challenges)
        * "Quiet environment"
        * "Social connection focused"
3. **Buddy Preferences (Optional):**
    * preferredBuddyLifeStage: (Multi-select, optional) Allows users to specify if they're looking for buddies in a similar life stage (e.g., a new mom looking for another new mom).
    * preferredBuddyGender: (Optional) "Male," "Female," "Mixed Group," "No Preference." (This can be sensitive, so handle with care and make it clear it's for user comfort in pairing).
4. **Accessibility Needs (Optional, Free-text or Predefined):**
    * accessibilityNotes: (String, optional) A free-text field for users to mention any specific accessibility needs for locations or activities.
5. **About Me/Interests (Optional Free-text):**
    * bio: (String, optional) A short bio where users can share more about themselves, their fitness journey, or what they're looking for in a PushPal. This allows for more organic matching beyond structured data.

# New Availability Screen Enhancements:
1. **Workout-Specific Preferences:**
    * For each preferredWorkoutType, allow specifying:
        * intensityPreference (e.g., "Low," "Medium," "High") for that specific workout.
        * durationPreference (e.g., "30min," "1hr") for that specific workout.
        * notes (e.g., "Need a place with childcare nearby for this," "Prefer indoor for this").
2. Implementation Considerations:
    * **Phased Rollout:** You don't need to add all of these at once. Start with the most impactful ones for your target expansion groups.
    * **UI/UX:**
        * Keep the profile setup from becoming too overwhelming. Use optional fields, clear labeling, and perhaps group related questions.
        * For lifeStage or other sensitive information, clearly state why it's being asked and how it will be used (and that it's optional).
3. **Data Model Updates:**
    *  Each new field will require updating UserProfile model (domain, copyWith, toMap, fromMap).
4. **Screen Updates:**
    * CreateProfileScreen will need new UI elements for these fields.
    * AvailabilityScreen might need adjustments if you add workout-specific preferences there.
5. **Matching Logic:**
    * Your backend/matching logic will need to be updated to utilize these new fields effectively.
6. **Next Steps Recommendation:**
    * Choose 1-3 new fields that you think would be most immediately beneficial for the groups you want to include (e.g., "Life Stage," "Intensity Preference," and adding more granular "Workout Types" and "Fitness Goals").
    * We can then work on:
        * Updating the UserProfile model.
        * Adding the UI elements to CreateProfileScreen.
        * Adjusting AvailabilityScreen if needed.