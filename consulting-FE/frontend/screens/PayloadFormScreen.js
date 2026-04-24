// frontend/screens/PayloadFormScreen.js
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, Button, StyleSheet, Alert } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

const TOTAL_STEPS = 9;

export default function PayloadFormScreen({ navigation }) {
    const [step, setStep] = useState(0);

    const [payload, setPayload] = useState({
        name: "",
        physique: { height: "", weight: "", gender: "", age: "" },
        goalType: "",
        experience: "",
        daysPerWeek: 0,
        diet: null,
    });

    const updatePhysique = (field, value) => {
        setPayload((prev) => ({
            ...prev,
            physique: { ...prev.physique, [field]: value },
        }));
    };

    const updateField = (field, value) => {
        setPayload((prev) => ({ ...prev, [field]: value }));
    };

    const buildFinalPayload = () => ({
        name: payload.name.trim(),
        physique: {
            height: Number(payload.physique.height) || 0,
            weight: Number(payload.physique.weight) || 0,
            gender: payload.physique.gender,
            age: Number(payload.physique.age) || 0,
        },
        goalType: payload.goalType,
        experience: payload.experience,
        daysPerWeek: Number(payload.daysPerWeek) || 0,
        diet: !!payload.diet,
    });

    const renderStep = () => {
        switch (step) {
            case 0:
                return (
                    <>
                        <Text style={styles.label}>Enter your name</Text>
                        <TextInput
                            placeholder="e.g. Minsoo"
                            value={payload.name}
                            onChangeText={(v) => updateField("name", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 1:
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
            case 2:
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
            case 5:
                return (
                    <>
                        <Text style={styles.label}>Enter Goal Type</Text>
                        <TextInput
                            placeholder="e.g. hypertrophy, weight loss"
                            value={payload.goalType}
                            onChangeText={(v) => updateField("goalType", v)}
                            style={styles.input}
                        />
                    </>
                );
            case 6:
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
            case 7:
                return (
                    <>
                        <Text style={styles.label}>Workout days per week</Text>
                        <View style={{ flexDirection: "row", flexWrap: "wrap" }}>
                            {[1, 2, 3, 4, 5, 6, 7].map((d) => (
                                <TouchableOpacity
                                    key={d}
                                    onPress={() => updateField("daysPerWeek", d)}
                                    style={[
                                        styles.button,
                                        payload.daysPerWeek === d && styles.buttonSelected,
                                    ]}
                                >
                                    <Text style={styles.buttonText}>{d}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </>
                );
            case 8:
                return (
                    <>
                        <Text style={styles.label}>Include diet plan?</Text>
                        <View style={{ flexDirection: "row" }}>
                            {[
                                { label: "Yes", value: true },
                                { label: "No", value: false },
                            ].map((opt) => (
                                <TouchableOpacity
                                    key={opt.label}
                                    onPress={() => updateField("diet", opt.value)}
                                    style={[
                                        styles.button,
                                        payload.diet === opt.value && styles.buttonSelected,
                                    ]}
                                >
                                    <Text style={styles.buttonText}>{opt.label}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
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
                                    const finalPayload = buildFinalPayload();
                                    await AsyncStorage.setItem("payload", JSON.stringify(finalPayload));
                                    console.log("Saved payload:", finalPayload);
                                    navigation.navigate("PlanScreen");
                                } catch (e) {
                                    console.error("Error saving payload:", e);
                                    Alert.alert("Error", "Failed to save payload");
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

            {step < TOTAL_STEPS && (
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
