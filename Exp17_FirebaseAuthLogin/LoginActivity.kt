package com.example.loginapp

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {

    private lateinit var username: EditText
    private lateinit var password: EditText
    private lateinit var loginBtn: Button
    private lateinit var signupBtn: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        username = findViewById(R.id.username)
        password = findViewById(R.id.password)
        loginBtn = findViewById(R.id.loginBtn)
        signupBtn = findViewById(R.id.signupBtn)

        val prefs: SharedPreferences = getSharedPreferences("UserData", MODE_PRIVATE)

        loginBtn.setOnClickListener {
            val user = username.text.toString()
            val pass = password.text.toString()

            val savedUser = prefs.getString("username", null)
            val savedPass = prefs.getString("password", null)

            when {
                user.isEmpty() || pass.isEmpty() ->
                    Toast.makeText(this, "Fields cannot be empty", Toast.LENGTH_SHORT).show()

                user == savedUser && pass == savedPass -> {
                    Toast.makeText(this, "Login Successful", Toast.LENGTH_SHORT).show()
                    startActivity(Intent(this, MainActivity::class.java))
                    finish()
                }

                else -> Toast.makeText(this, "Invalid credentials", Toast.LENGTH_SHORT).show()
            }
        }

        signupBtn.setOnClickListener {
            startActivity(Intent(this, SignupActivity::class.java))
        }
    }
}
