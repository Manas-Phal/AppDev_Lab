package com.example.loginapp

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class SignupActivity : AppCompatActivity() {

    private lateinit var username: EditText
    private lateinit var password: EditText
    private lateinit var confirmPassword: EditText
    private lateinit var registerBtn: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_signup)

        username = findViewById(R.id.username)
        password = findViewById(R.id.password)
        confirmPassword = findViewById(R.id.confirmPassword)
        registerBtn = findViewById(R.id.registerBtn)

        val prefs: SharedPreferences = getSharedPreferences("UserData", MODE_PRIVATE)
        val editor = prefs.edit()

        registerBtn.setOnClickListener {
            val user = username.text.toString()
            val pass = password.text.toString()
            val confirmPass = confirmPassword.text.toString()

            when {
                user.isEmpty() || pass.isEmpty() -> {
                    Toast.makeText(this, "Fields cannot be empty", Toast.LENGTH_SHORT).show()
                }
                pass != confirmPass -> {
                    Toast.makeText(this, "Passwords do not match", Toast.LENGTH_SHORT).show()
                }
                else -> {
                    editor.putString("username", user)
                    editor.putString("password", pass)
                    editor.apply()
                    Toast.makeText(this, "Signup Successful", Toast.LENGTH_SHORT).show()
                    startActivity(Intent(this, MainActivity::class.java))
                    finish()
                }
            }
        }
    }
}
