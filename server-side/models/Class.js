const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Class = sequelize.define('Class', {
    class_name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    main_teacher_id: {
        type: DataTypes.INTEGER,
        allowNull: true
    }
});

module.exports = Class;
