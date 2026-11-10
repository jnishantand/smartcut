const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// 1. Trigger: Booking Confirmation
exports.onBookingCreated = functions.firestore
    .document("bookings/{bookingId}")
    .onCreate(async (snap, context) => {
      const booking = snap.data();
      const userId = booking.userId;

      // Example format, adapt to your schema
      const title = "Booking Confirmed!";
      const body = `Your appointment for ${booking.serviceName} is confirmed for ${booking.date} at ${booking.time}. ID: ${context.params.bookingId}`;

      await createAndSendNotification(userId, title, body, "booking");
    });

// 2. Trigger: Payment Verified (assuming you have a payments collection or status update)
exports.onPaymentVerified = functions.firestore
    .document("bookings/{bookingId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      // Check if status changed to 'paid'
      if (before.paymentStatus !== "paid" && after.paymentStatus === "paid") {
        const title = "Payment Successful";
        const body = `Your payment of ${after.amount} was received. Ref: ${after.transactionRef}`;
        await createAndSendNotification(after.userId, title, body, "payment");
      }
    });

// 3. Trigger: Booking Updates (Reschedule/Cancel)
exports.onBookingUpdated = functions.firestore
    .document("bookings/{bookingId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      let body = null;
      const type = "booking";

      if (before.status !== "cancelled" && after.status === "cancelled") {
        body = `Your appointment for ${after.serviceName} has been cancelled.`;
      } else if (before.time !== after.time || before.date !== after.date) {
        body = `Your appointment has been rescheduled to ${after.date} at ${after.time}.`;
      }

      if (body) {
        await createAndSendNotification(after.userId, "Booking Update", body, type);
      }
    });

// 4. Scheduled Reminder: 15 mins before appointment
// Runs every 5 minutes to find upcoming appointments
exports.appointmentReminders = functions.pubsub.schedule("every 5 minutes").onRun(async (context) => {
  const now = new Date();
  const fifteenMinsFromNow = new Date(now.getTime() + 15 * 60000);
  const twentyMinsFromNow = new Date(now.getTime() + 20 * 60000);

  // Query bookings that are happening in the next 15-20 minutes window
  // This requires your date/time to be stored as Firestore Timestamps
  const upcomingBookings = await admin.firestore().collection("bookings")
      .where("appointmentTimestamp", ">=", fifteenMinsFromNow)
      .where("appointmentTimestamp", "<", twentyMinsFromNow)
      .where("status", "==", "confirmed")
      .get();

  for (const doc of upcomingBookings.docs) {
    const booking = doc.data();

    // Check user preferences
    const userDoc = await admin.firestore().collection("users").doc(booking.userId).get();
    const settings = userDoc.data() ? userDoc.data().notificationSettings : {};

    if (settings.appointmentReminders !== false) {
      const title = "Appointment Reminder";
      const body = `Your ${booking.serviceName} appointment is in 15 minutes!`;
      await createAndSendNotification(booking.userId, title, body, "reminder");
    }
  }
});

// 5. Callable: Admin sends Custom/Quiet Salon Notification
exports.sendAdminNotification = functions.https.onCall(async (data, context) => {
  // Basic Auth Check (In production, verify admin role in Firestore)
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in");
  }

  const {title, body, audience} = data;

  // Fetch users based on audience
  let usersQuery = admin.firestore().collection("users");

  if (audience === "promotional_opt_in") {
    usersQuery = usersQuery.where("notificationSettings.promotions", "==", true);
  }

  const usersSnap = await usersQuery.get();

  const batch = admin.firestore().batch();
  const tokens = [];

  usersSnap.forEach((doc) => {
    const userData = doc.data();
    const userId = doc.id;

    // 1. Add to history
    const notifRef = admin.firestore().collection("notifications").doc();
    batch.set(notifRef, {
      userId: userId,
      title: title,
      body: body,
      type: audience === "promotional_opt_in" ? "promotion" : "announcement",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. Collect Tokens
    if (userData.fcmTokens && Array.isArray(userData.fcmTokens)) {
      tokens.push(...userData.fcmTokens);
    }
  });

  await batch.commit();

  // 3. Send Push Notifications via FCM Multicast
  if (tokens.length > 0) {
    // Send in batches of 500 (FCM limit)
    for (let i = 0; i < tokens.length; i += 500) {
      const tokenBatch = tokens.slice(i, i + 500);
      const message = {
        notification: {title, body},
        tokens: tokenBatch,
      };
      await admin.messaging().sendMulticast(message);
    }
  }

  return {success: true, count: usersSnap.size};
});


// Helper Function to Create History Record & Send Push
async function createAndSendNotification(userId, title, body, type) {
  // 1. Save to History
  await admin.firestore().collection("notifications").add({
    userId,
    title,
    body,
    type,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 2. Fetch User FCM Tokens
  const userDoc = await admin.firestore().collection("users").doc(userId).get();
  const tokens = userDoc.data() ? userDoc.data().fcmTokens : null;

  // 3. Send Push Notification
  if (tokens && tokens.length > 0) {
    const message = {
      notification: {title, body},
      tokens: tokens,
    };
    try {
      await admin.messaging().sendMulticast(message);
    } catch (e) {
      console.error("Error sending message:", e);
    }
  }
}

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
