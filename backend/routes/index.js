const express = require('express');
const { protect, admin } = require("../middleware/auth");
const router = express.Router();
const homeController = require('../controllers/homeController');
const emailTestController = require('../controllers/emailTestController');
const {
    registerUser,
    loginUser,
    logoutUser,
    getUserProfile,
    getUserByEmail,
    updateUserProfile,
    adminUpdateUser,
    getUsers,
    deleteUser,
    forgotPassword
  } = require("../controllers/authController");
// Home route
router.get('/', homeController.getRoot);

// User routes
router.post("/register", registerUser);
router.post("/login", loginUser);
router.post("/logout", protect, logoutUser);
router.get("/profile", protect, getUserProfile);
router.put("/profile", protect, updateUserProfile);
router.put("admin/update-user-profile", protect,admin, adminUpdateUser);



router.get("/users", protect, admin, getUsers);
router.get("/user/email/:email", getUserByEmail);
router.delete("/user/:id", protect, admin, deleteUser);
router.post("/forgot-password", forgotPassword);

// CleverReach test routes (for development/testing only)
router.get("/test/cleverreach", emailTestController.testCleverReachConnection);
router.post("/test/send-invitation", emailTestController.testSendInvitation);
router.get("/test/cleverreach-debug", emailTestController.debugCleverReachAPI);

// Mailjet test routes (for development/testing only)
router.use("/mailjet-test", require("./mailjetTest"));



module.exports = router;
