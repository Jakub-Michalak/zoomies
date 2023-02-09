const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.createProfile = functions.auth.user().onCreate((user) => {
  const userObject = {
    displayName: user.displayName,
    email: user.email,
    avatarURL: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
    inviteCode: null,
    totalScore: 0,
    lastSyncDate: 0,
  };
  return admin.firestore().doc("Users/" + user.uid).set(userObject);
});

exports.createGuild = functions.https.onCall((data, context) => {
  // This function generates an inviteCode for guild that is being created
  function generateInviteCode() {
    let code = "";
    // Characters such as 1/I, 8/B, 0/O removed to avoid user confusion
    const characters = "ACDEFGHJKLMNPQRSTUVWXYZ2345679";
    for (let i = 0; i < 6; i++) {
      code += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return code;
  }
  const code = generateInviteCode();
  const guildObject = {
    name: data.name,
    inviteCode: code,
    adminUID: context.auth.uid,
  };
  const goalObject = {
    CurrentPoints: 0,
    Name: "Goal",
    RequiredPoints: 10000,
  };
    admin.firestore().doc("Guilds/" + code).set(guildObject);
    console.log("Guild created: " + code);
    admin.firestore().doc("Guilds/" + code + "/Goals/CurrentGoal").set(goalObject);
    return {status: "OK", code: code};
  });

// requires data.inviteCode
exports.joinGuild = functions.https.onCall(async(data, context) => {
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();
  const userInGuildObject = {
    AvatarURL: userDoc.avatarURL || "",
    CurrentScore: 0,
    Name: userDoc.displayName || "No name",
  };
  return admin.firestore().doc("Guilds/" + data.inviteCode + "/Users/" + uid).set(userInGuildObject).then(() => {
    console.log("User added to guild: " + data.inviteCode);
    admin.firestore().doc("Users/" + uid).update({inviteCode: data.inviteCode});
    return {status: "OK"};
  });
});

exports.leaveGuild = functions.https.onCall(async(data, context) => {
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();
  const oldInviteCode = userDoc.inviteCode;

  return admin.firestore().doc("Guilds/" + oldInviteCode + "/Users/" + uid).delete().then(() => {
    console.log("User removed from guild: " + oldInviteCode);
    admin.firestore().doc("Users/" + uid).update({inviteCode: null});
    return {status: "OK"};
  });
});

//requires data.activities[]
exports.syncActivities = functions.https.onCall(async(data, context) => { 
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();
  const lastSyncDate = userDoc.lastSyncDate;
  const activityArray = JSON.parse(data.activities);

  for(let i=0; i < activityArray.length; i++)
  {
    let activityDistance = parseFloat(activityArray[i].workoutDistance).toFixed(2);
    //conversion from UNIX timestamp to NSDate
    let activityDate = activityArray[i].workoutEnd + 978307200;
    
    if(activityDate > lastSyncDate){
      //point calculation
      let scoreAddition = parseInt(activityDistance * 237);
      console.log("Adding " + scoreAddition + " points");
      admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Users/" + uid).update({CurrentScore: admin.firestore.FieldValue.increment(scoreAddition)});
      admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Goals/CurrentGoal").update({CurrentPoints: admin.firestore.FieldValue.increment(scoreAddition)});
      admin.firestore().doc("Users/" + uid).update({totalScore: admin.firestore.FieldValue.increment(scoreAddition)});
    }
  }

  admin.firestore().doc("Users/" + uid).update({lastSyncDate: Math.floor(Date.now() / 1000)});
  return {status: "OK"};
});

exports.checkGuild = functions.https.onCall(async(data, context) => {
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();

  if(userDoc.inviteCode === null)return {status: "OK", hasGuild: "false"};
  else return {status: "OK", hasGuild: "true", code: userDoc.inviteCode};
});

exports.checkAdminPermissions = functions.https.onCall(async(data, context) => {
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();

  const guildResult = await admin.firestore().doc("Guilds/" + userDoc.inviteCode).get();
  const guildDoc = guildResult.data();

  if(uid === guildDoc.adminUID)return {status: "OK", isAdmin: "true"};
  else return {status: "OK", isAdmin: "false"};
});

exports.deleteGuild = functions.https.onCall(async(data, context) => {
  const uid = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + uid).get();
  const userDoc = result.data();

  const usersResult = await admin.firestore().collection("Guilds/" + userDoc.inviteCode + "/Users").get();

  usersResult.forEach((user) => {
    admin.firestore().doc("Users/" + user.id).update({inviteCode: null});
  })

    admin.firestore().recursiveDelete(admin.firestore().collection("Guilds/").doc(userDoc.inviteCode));
    console.log("Guild removed");
    return {status: "OK"};
});

//requires data.kickedUserUID
exports.kickFromGuild = functions.https.onCall(async(data, context) => {
  const adminUID = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + adminUID).get();
  const userDoc = result.data();

  admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Users/" + data.kickedUserUID).delete().then(() => {
    console.log("User kicked from guild: " + userDoc.inviteCode);
    admin.firestore().doc("Users/" + data.kickedUserUID).update({inviteCode: null});
    return {status: "OK"};
  });
});

//requires data.goalName, data.requiredPoints
exports.setGoal = functions.https.onCall(async(data, context) => {
  const adminUID = context.auth.uid;
  const result = await admin.firestore().doc("Users/" + adminUID).get();
  const userDoc = result.data();

  const goalResult = await admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Goals/CurrentGoal").get();
  admin.firestore().collection("Guilds/" + userDoc.inviteCode + "/Goals").add(goalResult.data());

  const goalObject = {
    CurrentPoints: 0,
    Name: data.goalName,
    RequiredPoints: parseInt(data.requiredPoints),
  };

    admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Goals/CurrentGoal").set(goalObject);
    
    const usersResult = await admin.firestore().collection("Guilds/" + userDoc.inviteCode + "/Users").get();

    usersResult.forEach((user) => {
      admin.firestore().doc("Guilds/" + userDoc.inviteCode + "/Users/" + user.id).update({CurrentScore: 0});
    })

    return {status: "OK"};
});