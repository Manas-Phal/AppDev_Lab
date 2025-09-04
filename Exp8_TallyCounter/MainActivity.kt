package com.example.tallycounter

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    private lateinit var counterText: TextView
    private lateinit var incrementButton: Button
    private lateinit var decrementButton: Button
    private lateinit var resetButton: Button
    private var counter = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize views
        counterText = findViewById(R.id.counterText)
        incrementButton = findViewById(R.id.incrementButton)
        decrementButton = findViewById(R.id.decrementButton)
        resetButton = findViewById(R.id.resetButton)

        // Button Click Listeners
        incrementButton.setOnClickListener {
            counter++
            updateCounter()
            showToast("Nice! Count is now $counter 📈")
        }

        decrementButton.setOnClickListener {
            counter--
            updateCounter()
            showToast("Oops! Count dropped to $counter 📉")
        }

        resetButton.setOnClickListener {
            counter = 0
            updateCounter()
            showToast("Counter reset. Back to zero! 🔄")
        }

        // Show initial counter
        updateCounter()
    }

    private fun updateCounter() {
        counterText.text = counter.toString()

        // Change text color based on value
        counterText.setTextColor(
            when {
                counter > 0 -> Color.parseColor("#388E3C") // Green
                counter < 0 -> Color.parseColor("#D32F2F") // Red
                else -> Color.parseColor("#1976D2")       // Blue
            }
        )
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    // Save state on rotate/background
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putInt("counter_value", counter)
    }

    override fun onRestoreInstanceState(savedInstanceState: Bundle) {
        super.onRestoreInstanceState(savedInstanceState)
        counter = savedInstanceState.getInt("counter_value")
        updateCounter()
    }
}
