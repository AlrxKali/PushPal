const functions = require("firebase-functions");
const {MongoClient, ServerApiVersion} = require("mongodb");

// It's good practice to initialize the MongoDB client
// outside the function handler to allow connection reuse for warm invocations.
let client;
let db;

/**
 * Initializes the MongoDB client and database connection.
 * @async
 * @return {Promise<object>} The database client.
 * @throws {functions.https.HttpsError} If connection fails or URI is missing.
 */
async function initializeDbClient() {
  if (!client || !client.topology || !client.topology.isConnected()) {
    // Retrieve the MongoDB URI from Firebase environment configuration
    // IMPORTANT: Set this using
    // \`firebase functions:config:set mongodb.uri="YOUR_URI"\`
    const uri = functions.config().mongodb.uri;
    if (!uri) {
      console.error(
          "MongoDB URI not set in Firebase environment configuration.",
      );
      throw new functions.https.HttpsError(
          "internal",
          "Server configuration error: MongoDB URI is missing.",
      );
    }

    client = new MongoClient(uri, {
      serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
      },
    });

    try {
      console.log("Attempting to connect to MongoDB...");
      await client.connect();
      db = client.db(); // The database name should be part of your URI
      console.log("Successfully connected to MongoDB!");
    } catch (error) {
      console.error("Failed to connect to MongoDB", error);
      // If connection fails, throw an error to prevent function execution
      throw new functions.https.HttpsError(
          "internal",
          "Could not connect to the database.",
      );
    }
  }
  return db;
}

/**
 * Firebase HTTPS Callable Function to fetch location details.
 * @param {object} data - The data passed to the function.
 * @param {string} data.zipCode - The zip code.
 * @param {string} data.countryCode - The country code
 * (e.g., 'USA', 'CAD', 'ESP').
 * @param {object} context - The context of the function call.
 * @return {Promise<object>} Object containing place_name, admin1_name,
 * country_code.
 * @throws {functions.https.HttpsError} For invalid arguments or internal
 * errors.
 */
exports.getLocationDetails = functions.https.onCall(async (data, context) => {
  // data will contain { zipCode: "...", countryCode: "..." }
  const zipCode = data.zipCode;
  const countryCode = data.countryCode; // Expected: 'USA', 'CAD', 'ESP'

  if (!zipCode || !countryCode) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing zipCode or countryCode.",
    );
  }

  let collectionName;
  switch (countryCode.toUpperCase()) {
    case "USA":
      collectionName = "us_zip_codes";
      break;
    case "CAD":
      collectionName = "ca_zip_codes";
      break;
    case "ESP":
      collectionName = "es_zip_codes";
      break;
    default:
      throw new functions.https.HttpsError(
          "invalid-argument",
          `Unsupported country code: ${countryCode}`,
      );
  }

  try {
    const database = await initializeDbClient();
    const collection = database.collection(collectionName);

    // Find the document matching the postal_code
    // Your example data has 'postal_code' as a string
    const locationDoc = await collection.findOne({postal_code: zipCode});

    if (!locationDoc) {
      throw new functions.https.HttpsError(
          "not-found",
          `No data found for zip code ${zipCode} in ${countryCode}.`,
      );
    }

    // Return the required fields
    return {
      place_name: locationDoc.place_name,
      admin1_name: locationDoc.admin1_name,
      // Or simply pass back the input countryCode
      country_code: locationDoc.country_code,
    };
  } catch (error) {
    console.error("Error fetching location details:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error; // Re-throw HttpsError directly
    }
    throw new functions.https.HttpsError(
        "internal",
        "An error occurred while fetching location details.",
    );
  }
});

