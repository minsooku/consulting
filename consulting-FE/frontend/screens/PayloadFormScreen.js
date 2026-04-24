// frontend/screens/PayloadFormScreen.js
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, Button, StyleSheet, Alert } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Calendar } from "react-native-calendars";

export default function PayloadFormScreen({ navigation }) {
    const [step, setStep] = useState(0);

    const [payload, setPayload] = useState({
        physique: { height: "", weight: "", gender: "", age: "" },
        goalType: "",
        experience: "",
        hoursPerWeek: 0,
        constraints: "",
        preferences: "",
        dietEffort: "",
        startDate: "",
        endDate: "",
    });

    const updatePhysique = (field, value) => {
        setPayload((prev) => ({
            ...prev,
            physique: { ...prev.physique, [field]: value },
        }));
    };

    const updateField = (field, value) => {
        setPayload((prev) => {
            let updated = { ...prev, [field]: value };

            if (field === "startDate") {
                const start = new Date(value);
                if (!isNaN(start.getTime())) {
                    const end = new Date(start);
                    end.setDate(start.getDate() + 28); // +4 weeks
                    const endStr = end.toISOString().split("T")[0]; // YYYY-MM-DD
                    updated.endDate = endStr;
                }
            }

            return updated;
        });
    };

    const savePayload = async () => {
        try {
            await AsyncStorage.setItem("payload", JSON.stringify(payload));
            Alert.alert("Success", "Payload saved locally!");
            console.log("Saved payload:", payload);
            navigation.goBack(); // go back after saving
        } catch (e) {
            console.error("Error saving payload:", e);
        }
    };

    // Steps content
    const renderStep = () => {
        switch (step) {
            case 0:
                return (
                    <>
                        <Text style={styles.label}>Enter your Height (cm)</Text>
                        <TextInput
                            placeholder="e.g. 180"
                            keyboardType="numeric"
                            value={payload.physique.height.toString()}
                            onChangeText={(v) => updatePhysique("height", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 1:
                return (
                    <>
                        <Text style={styles.label}>Enter your Weight (kg)</Text>
                        <TextInput
                            placeholder="e.g. 85"
                            keyboardType="numeric"
                            value={payload.physique.weight.toString()}
                            onChangeText={(v) => updatePhysique("weight", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 2:
                return (
                    <>
                        <Text style={styles.label}>Select Gender</Text>
                        <View style={{ flexDirection: "row" }}>
                            {["Male", "Female"].map((g) => (
                                <TouchableOpacity
                                    key={g}
                                    onPress={() => updatePhysique("gender", g)}
                                    style={[
                                        styles.button,
                                        payload.physique.gender === g && styles.buttonSelected,
                                    ]}
                                >
                                    <Text style={styles.buttonText}>{g}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </>
                );
            case 3:
                return (
                    <>
                        <Text style={styles.label}>Enter your Age</Text>
                        <TextInput
                            placeholder="e.g. 35"
                            keyboardType="numeric"
                            value={payload.physique.age.toString()}
                            onChangeText={(v) => updatePhysique("age", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 4:
                return (
                    <>
                        <Text style={styles.label}>Enter Goal Type</Text>
                        <TextInput
                            placeholder="e.g. hypertrophy"
                            value={payload.goalType}
                            onChangeText={(v) => updateField("goalType", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 5:
                return (
                    <>
                        <Text style={styles.label}>Select Experience</Text>
                        <View style={{ flexDirection: "row", flexWrap: "wrap" }}>
                            {["Beginner", "Intermediate", "Advanced"].map((exp) => (
                                <TouchableOpacity
                                    key={exp}
                                    onPress={() => updateField("experience", exp)}
                                    style={[
                                        styles.button,
                                        payload.experience === exp && styles.buttonSelected,
                                    ]}
                                >
                                    <Text style={styles.buttonText}>{exp}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </>
                );
            case 6:
                return (
                    <>
                        <Text style={styles.label}>Select Hours per Week</Text>
                        <View style={{ flexDirection: "row", flexWrap: "wrap" }}>
                            {[3, 6, 9, 12, 15].map((h) => (
                                <TouchableOpacity
                                    key={h}
                                    onPress={() => updateField("hoursPerWeek", h)}
                                    style={[
                                        styles.button,
                                        payload.hoursPerWeek === h && styles.buttonSelected,
                                    ]}
                                >
                                    <Text style={styles.buttonText}>{h}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </>
                );
  case 7:
        return (
          <>
            <Text style={styles.label}>Select Start Date</Text>
            <Calendar
              onDayPress={(day) => updateField("startDate", day.dateString)}
              markedDates={{
                [payload.startDate]: { selected: true, selectedColor: "blue" },
              }}
            />
            <Text style={{ marginTop: 10 }}>
              Selected Start Date: {payload.startDate}
            </Text>
            <Text>Calculated End Date: {payload.endDate}</Text>
          </>
        );
            case 8:
                return (
                    <>
                        <Text style={styles.label}>Constraints</Text>
                        <TextInput
                            placeholder="e.g. knee injury"
                            value={payload.constraints}
                            onChangeText={(v) => updateField("constraints", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 9:
                return (
                    <>
                        <Text style={styles.label}>Preferences</Text>
                        <TextInput
                            placeholder="e.g. like swimming"
                            value={payload.preferences}
                            onChangeText={(v) => updateField("preferences", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 10:
                return (
                    <>
                        <Text style={styles.label}>Diet Effort</Text>
                        <TextInput
                            placeholder="e.g. strict"
                            value={payload.dietEffort}
                            onChangeText={(v) => updateField("dietEffort", v)}
                            style={styles.input}
                        />
                    </>
                );
            default:
                return (
                    <View>
                        <Text style={styles.label}>All steps complete!</Text>
                        <Button
                            title="Save Payload & Go to PlanScreen"
                            onPress={async () => {
                                try {
                                    // Save payload to AsyncStorage
                                    await AsyncStorage.setItem("payload", JSON.stringify(payload));
                                    console.log("Saved payload:", payload);

                                    // Navigate to PlanScreen
                                    navigation.navigate("PlanScreen");
                                } catch (e) {
                                    console.error("Error saving payload:", e);
                                }
                            }}
                        />
                    </View>
                );
        }
    };

    return (
        <View style={{ flex: 1, padding: 20 }}>
            {renderStep()}

            {step <= 10 && (
                <Button title="Next" onPress={() => setStep(step + 1)} />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    label: { fontSize: 18, marginBottom: 8 },
    input: {
        borderWidth: 1,
        padding: 10,
        marginBottom: 20,
        borderRadius: 6,
    },
    button: {
        padding: 10,
        margin: 5,
        backgroundColor: "gray",
        borderRadius: 6,
    },
    buttonSelected: {
        backgroundColor: "blue",
    },
    buttonText: { color: "white" },
});