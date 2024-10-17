const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
    const { username, password, role } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const newUser = await User.create({
            username,
            password_hash: hashedPassword,
            role
        });
        res.status(201).json(newUser);
    } catch (error) {
        res.status(500).json({ error: 'User registration failed.' });
    }
};

exports.login = async (req, res) => {
    const { username, password } = req.body;

    try {
        const user = await User.findOne({ where: { username } });
        if (user && await bcrypt.compare(password, user.password_hash)) {
            const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET);
            await user.update({ login_token: token });
            res.json({ token });
        } else {
            res.status(401).json({ error: 'Invalid credentials.' });
        }
    } catch (error) {
        res.status(500).json({ error: 'Login failed.' });
    }
};
