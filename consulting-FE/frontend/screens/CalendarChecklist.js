// frontend/screens/CalendarChecklist.js
import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Calendar } from "react-native-calendars";
import { useIsFocused } from "@react-navigation/native";

export default function CalendarChecklist() {
  const [dailyPlans, setDailyPlans] = useState([]);
  const [weeklyPlans, setWeeklyPlans] = useState([]);
  const [selectedDate, setSelectedDate] = useState(
    new Date().toISOString().slice(0, 10)
  );
  const [viewMode, setViewMode] = useState("daily"); // 'daily' | 'weekly'
  const [checklist, setChecklist] = useState({ daily: {}, weekly: {} });
  const [planStartDate, setPlanStartDate] = useState(null); // payload startDate
  const isFocused = useIsFocused();

  // Load plans & payload from AsyncStorage
  useEffect(() => {
    const loadData = async () => {
      try {
        const plansStr = await AsyncStorage.getItem("plans");
        const plans = plansStr ? JSON.parse(plansStr) : [];

        const payloadStr = await AsyncStorage.getItem("payload");
        const payload = payloadStr ? JSON.parse(payloadStr) : null;
        if (payload?.startDate) setPlanStartDate(payload.startDate); // Use startDate from payload to calculate the week based on selected day

        // Flatten all daily/weekly plans from all saved plans
        const allDaily = plans.flatMap((plan) =>
          (plan.daily || []).map((day) => ({
            ...day,
            blocks: (day.blocks || []).map((block) => ({
              ...block,
              planName: plan.name,
            })),
          }))
        );
        const allWeekly = plans.flatMap((plan) =>
          (plan.weekly || []).map((week) => ({ ...week, planName: plan.name }))
        );

        setDailyPlans(allDaily);
        setWeeklyPlans(allWeekly);
      } catch (err) {
        console.error("Error loading plans:", err);
      }
    };

    if (isFocused) loadData();
  }, [isFocused]);

  // Toggle check for daily or weekly
  const toggleCheck = (type, blockIdx, detailIdx) => {
    setChecklist((prev) => {
      const newChecks = { ...prev };
      if (!newChecks[type]) newChecks[type] = {};
      if (!newChecks[type][blockIdx]) newChecks[type][blockIdx] = {};
      newChecks[type][blockIdx][detailIdx] =
        !newChecks[type][blockIdx][detailIdx];
      return newChecks;
    });
  };

  // Calculate the week order based on selected Day
  const getWeekNumber = (selectedDate, startDate) => {
    if (!startDate) return 1;
    const start = new Date(startDate);
    const selected = new Date(selectedDate);

    // Sunday is the starting of the week
    const startSunday = new Date(start);
    startSunday.setDate(startSunday.getDate() - startSunday.getDay());

    const selectedSunday = new Date(selected);
    selectedSunday.setDate(selectedSunday.getDate() - selectedSunday.getDay());

    const diffWeeks = Math.floor(
      (selectedSunday - startSunday) / (1000 * 60 * 60 * 24 * 7)
    );
    return diffWeeks + 1; // Start week_number as 1
  };

  const selectedWeekNumber = getWeekNumber(selectedDate, planStartDate);

  // Filter tasks to show like on weeekly mode it shows only weekly plan that selected day belongs to
  const tasksToShow =
    viewMode === "daily"
      ? dailyPlans.find((d) => d.date === selectedDate)?.blocks || []
      : weeklyPlans
          .filter((week) => week.week_number === selectedWeekNumber)
          .map((week) => ({
            title: week.theme,
            details: week.details || [],
            planName: week.planName,
          }));

  // Calculate progress
  const progress =
    tasksToShow.length === 0
      ? 0
      : Math.round(
          tasksToShow.reduce((doneCount, block, bIdx) => {
            const blockDetails = block.details || [];
            const checked = blockDetails.filter(
              (_, dIdx) => checklist[viewMode]?.[bIdx]?.[dIdx]
            ).length;
            return doneCount + checked;
          }, 0) /
            tasksToShow.reduce(
              (total, block) => total + (block.details?.length || 0),
              0
            ) *
            100
        );

  // Category color
  const getCategoryColor = (category) => {
    switch (category) {
      case "workout":
        return "#f05454";
      case "nutrition":
        return "#30475e";
      case "recovery":
        return "#3da5d9";
      case "habit":
        return "#f5a623";
      default:
        return "#999";
    }
  };

  return (
    <View style={{ flex: 1 }}>
      {/* Calendar */}
      <Calendar
        onDayPress={(day) => setSelectedDate(day.dateString)}
        markedDates={dailyPlans.reduce((acc, day) => {
          acc[day.date] = { marked: true };
          if (day.date === selectedDate) {
            acc[day.date].selected = true;
            acc[day.date].selectedColor = "#00adf5";
          }
          return acc;
        }, {})}
        style={{ marginBottom: 10 }}
      />

      {/* Navigation bar */}
      <View
        style={{
          flexDirection: "row",
          justifyContent: "center",
          marginBottom: 10,
        }}
      >
        {["daily", "weekly"].map((mode) => (
          <TouchableOpacity
            key={mode}
            onPress={() => setViewMode(mode)}
            style={[
              styles.navButton,
              viewMode === mode && styles.navButtonSelected,
            ]}
          >
            <Text style={{ color: "white", fontWeight: "bold" }}>
              {mode.toUpperCase()}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Progress */}
      <Text style={{ textAlign: "center", marginBottom: 10 }}>
        Progress: {progress}%
      </Text>

      {/* Checklist */}
      <ScrollView style={{ flex: 1, paddingHorizontal: 10 }}>
        {tasksToShow.map((block, bIdx) => (
          <View key={`${viewMode}-${bIdx}`} style={{ marginBottom: 10 }}>
            <View style={styles.blockHeader}>
              <Text style={styles.blockTitle}>{block.title}</Text>
              {block.planName && (
                <Text style={styles.planNameTag}>{block.planName}</Text>
              )}
            </View>
            {(block.details || []).map((d, dIdx) => (
              <TouchableOpacity
                key={dIdx}
                style={[
                  styles.checkItem,
                  { borderLeftColor: getCategoryColor(d.category) },
                ]}
                onPress={() => toggleCheck(viewMode, bIdx, dIdx)}
              >
                <Text>
                  {checklist[viewMode]?.[bIdx]?.[dIdx] ? "✅" : "⬜"} {d.label}{" "}
                  {d.unit ? `(${d.target_value} ${d.unit})` : ""}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  navButton: {
    padding: 10,
    marginHorizontal: 5,
    backgroundColor: "gray",
    borderRadius: 6,
  },
  navButtonSelected: {
    backgroundColor: "#00adf5",
  },
  checkItem: {
    borderLeftWidth: 5,
    padding: 10,
    marginVertical: 5,
    backgroundColor: "#f0f0f0",
    borderRadius: 6,
  },
  blockHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 5,
  },
  blockTitle: {
    fontWeight: "bold",
  },
  planNameTag: {
    fontSize: 10,
    color: "#fff",
    backgroundColor: "gray",
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 8,
  },
});
