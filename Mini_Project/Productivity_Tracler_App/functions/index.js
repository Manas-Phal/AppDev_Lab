const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.setUserRole = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  const role = data.role;

  if (!uid || !role) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Both 'uid' and 'role' must be provided."
    );
  }

  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can assign roles."
    );
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
  if (!callerDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Caller user not found.");
  }

  const callerRole = callerDoc.data().role || "guest";
  if (!callerRole.startsWith("admin")) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can assign roles."
    );
  }

  await admin.firestore().collection("users").doc(uid).set({ role: role }, { merge: true });
  return { message: `Role '${role}' assigned to UID ${uid}` };
});

