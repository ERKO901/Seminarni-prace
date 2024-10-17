const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
    username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    password_hash: {
        type: DataTypes.STRING,
        allowNull: false
    },
    role: {
        type: DataTypes.ENUM('admin', 'teacher', 'student', 'parent'),
        allowNull: false
    },
    login_token: {
        type: DataTypes.STRING,
        allowNull: true
    }
});

module.exports = User;
