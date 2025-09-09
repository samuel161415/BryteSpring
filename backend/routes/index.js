const express = require('express');
const { protect, admin } = require("../middleware/authMiddleware");
const router = express.Router();
const homeController = require('../controllers/homeController');
const {
    registerUser,
    loginUser,
    logoutUser,
    getUserProfile,
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
router.delete("/user/:id", protect, admin, deleteUser);
router.post("/forgot-password", forgotPassword);



module.exports = router;
