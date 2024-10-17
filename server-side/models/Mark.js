const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Mark = sequelize.define('Mark', {
    student_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    subject_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    teacher_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    mark: {
        type: DataTypes.DECIMAL(3, 2),
        allowNull: false
    },
    date_assigned: {
        type: DataTypes.DATE,
        allowNull: false
    },
    comment: {
        type: DataTypes.TEXT,
        allowNull: true
    }
});

module.exports = Mark;
