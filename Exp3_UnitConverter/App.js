import React, { useState } from "react";
import "./App.css";

export default function App() {
  const [conversionType, setConversionType] = useState("distance");
  const [input, setInput] = useState("");
  const [result, setResult] = useState("");

  const conversions = {
    distance: [
      { label: "Meters to Kilometers", factor: 0.001 },
      { label: "Kilometers to Meters", factor: 1000 },
      { label: "Miles to Kilometers", factor: 1.60934 },
    ],
    temperature: [
      { label: "Celsius to Fahrenheit", calc: (c) => (c * 9) / 5 + 32 },
      { label: "Fahrenheit to Celsius", calc: (f) => ((f - 32) * 5) / 9 },
    ],
    weight: [
      { label: "Grams to Kilograms", factor: 0.001 },
      { label: "Kilograms to Grams", factor: 1000 },
      { label: "Pounds to Kilograms", factor: 0.453592 },
    ],
  };

  const [selectedConversion, setSelectedConversion] = useState(
    conversions[conversionType][0]
  );

  const handleConvert = () => {
    let value = parseFloat(input);
    if (isNaN(value)) {
      setResult("Enter a number");
      return;
    }

    if (selectedConversion.calc) {
      setResult(selectedConversion.calc(value).toFixed(2));
    } else {
      setResult((value * selectedConversion.factor).toFixed(2));
    }
  };

  return (
    <div className="app">
      <h1>🌟 Unit Converter</h1>

      <div className="section">
        <label>Conversion Type: </label>
        <select
          value={conversionType}
          onChange={(e) => {
            setConversionType(e.target.value);
            setSelectedConversion(conversions[e.target.value][0]);
            setResult("");
          }}
        >
          <option value="distance">Distance</option>
          <option value="temperature">Temperature</option>
          <option value="weight">Weight</option>
        </select>
      </div>

      <div className="section">
        <label>Conversion:</label>
        <select
          value={selectedConversion.label}
          onChange={(e) =>
            setSelectedConversion(
              conversions[conversionType].find((c) => c.label === e.target.value)
            )
          }
        >
          {conversions[conversionType].map((conv) => (
            <option key={conv.label}>{conv.label}</option>
          ))}
        </select>
      </div>

      <div className="section">
        <label>Enter value:</label>
        <input
          type="number"
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
      </div>

      <button onClick={handleConvert}>Convert</button>

      {result && (
        <div className="result">
          <strong>Result:</strong> {result}
        </div>
      )}
    </div>
  );
}
