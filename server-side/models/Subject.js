const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Subject = sequelize.define('Subject', {
    subject_name: {
        type: DataTypes.STRING,
        allowNull: false
    }
});

module.exports = Subject;
