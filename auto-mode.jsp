<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    final int MAX_SIZE = 5;
    final int MAX_STEPS = 20;

    Queue<String> buffer = (Queue<String>) session.getAttribute("buffer");
    List<String> operationLog = (List<String>) session.getAttribute("operationLog");
    Integer producerCount = (Integer) session.getAttribute("producerCount");
    Integer consumerCount = (Integer) session.getAttribute("consumerCount");
    Integer producerWaits = (Integer) session.getAttribute("producerWaits");
    Integer consumerWaits = (Integer) session.getAttribute("consumerWaits");
    List<Integer> bufferHistory = (List<Integer>) session.getAttribute("bufferHistory");
    Integer stepCount = (Integer) session.getAttribute("stepCount");
    Boolean isRunning = (Boolean) session.getAttribute("isRunning");

    if (buffer == null) {
        buffer = new LinkedList<>(); session.setAttribute("buffer", buffer);
    }
    if (operationLog == null) {
        operationLog = new ArrayList<>(); session.setAttribute("operationLog", operationLog);
    }
    if (producerCount == null) {
        producerCount = 1; session.setAttribute("producerCount", producerCount);
    }
    if (consumerCount == null) {
        consumerCount = 1; session.setAttribute("consumerCount", consumerCount);
    }
    if (producerWaits == null) {
        producerWaits = 0; session.setAttribute("producerWaits", producerWaits);
    }
    if (consumerWaits == null) {
        consumerWaits = 0; session.setAttribute("consumerWaits", consumerWaits);
    }
    if (bufferHistory == null) {
        bufferHistory = new ArrayList<>(); session.setAttribute("bufferHistory", bufferHistory);
    }
    if (stepCount == null) {
        stepCount = 0; session.setAttribute("stepCount", stepCount);
    }
    if (isRunning == null) {
        isRunning = false; session.setAttribute("isRunning", isRunning);
    }

    String action = request.getParameter("action");
    if ("start".equals(action)) {
        session.setAttribute("isRunning", true);
    } else if ("stop".equals(action)) {
        session.setAttribute("isRunning", false);
    } else if ("restart".equals(action)) {
        buffer.clear(); operationLog.clear(); bufferHistory.clear();
        session.setAttribute("producerCount", 1);
        session.setAttribute("consumerCount", 1);
        session.setAttribute("producerWaits", 0);
        session.setAttribute("consumerWaits", 0);
        session.setAttribute("stepCount", 0);
        session.setAttribute("isRunning", false);
        operationLog.add("🔄 Simulation restarted: Buffer and counters reset.");
    }

    String result = "";
    if ((Boolean) session.getAttribute("isRunning")) {
        Random rand = new Random();
        int decision = rand.nextInt(2);

        if (decision == 0) {
            if (buffer.size() >= MAX_SIZE) {
                result = "⏳ Buffer full. Producer waiting...";
                producerWaits++;
                session.setAttribute("producerWaits", producerWaits);
            } else {
                int item = rand.nextInt(100);
                String producer = "Producer-" + producerCount;
                buffer.add(item + " (" + producer + ")");
                result = "✅ " + producer + " produced item: " + item;
                session.setAttribute("producerCount", producerCount + 1);
            }
        } else {
            if (buffer.isEmpty()) {
                result = "⏳ Buffer empty. Consumer waiting...";
                consumerWaits++;
                session.setAttribute("consumerWaits", consumerWaits);
            } else {
                String consumer = "Consumer-" + consumerCount;
                String removed = buffer.poll();
                result = "✅ " + consumer + " consumed item: " + removed;
                session.setAttribute("consumerCount", consumerCount + 1);
            }
        }

        bufferHistory.add(buffer.size());
        operationLog.add(result);
        stepCount++;
        session.setAttribute("stepCount", stepCount);

        if (stepCount >= MAX_STEPS) {
            session.setAttribute("isRunning", false);
            operationLog.add("⏹️ Simulation auto-stopped after " + MAX_STEPS + " steps.");
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Producer-Consumer Simulation</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <% if ((Boolean) session.getAttribute("isRunning")) { %>
        <meta http-equiv="refresh" content="2">
    <% } %>
</head>
<body class="min-h-screen bg-gradient-to-br from-blue-100 to-purple-100 flex flex-col items-center py-8 px-4">

    <div class="grid grid-cols-2 gap-6 w-full max-w-6xl">
        <!-- Metrics Panel -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-indigo-700 mb-4">📊 Performance Metrics</h2>
            <div class="grid grid-cols-2 gap-4 text-center">
                <div class="bg-blue-100 p-4 rounded-xl shadow"><strong>Total Produced</strong><br><%= producerCount - 1 %></div>
                <div class="bg-blue-100 p-4 rounded-xl shadow"><strong>Total Consumed</strong><br><%= consumerCount - 1 %></div>
                <div class="bg-blue-100 p-4 rounded-xl shadow"><strong>Buffer Usage</strong><br><%= (int)(((double)buffer.size()/MAX_SIZE)*100) %> %</div>
                <div class="bg-blue-100 p-4 rounded-xl shadow"><strong>Waits (P/C)</strong><br><%= producerWaits %> / <%= consumerWaits %></div>
                <div class="bg-blue-100 p-4 rounded-xl shadow col-span-2"><strong>Steps Taken</strong><br><%= stepCount %> / <%= MAX_STEPS %></div>
            </div>
        </div>

        <!-- Buffer State + Control -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-2">📦 Current Buffer</h2>
            <div class="flex flex-wrap justify-center gap-2">
                <% int i = 0; for (String item : buffer) { %>
                    <div class="w-28 h-14 flex items-center justify-center bg-white border border-indigo-500 rounded-lg shadow text-sm"><%= item %></div>
                <% i++; } while (i < MAX_SIZE) { %>
                    <div class="w-28 h-14 flex items-center justify-center bg-gray-200 border border-dashed rounded-lg text-gray-500">Empty</div>
                <% i++; } %>
            </div>

            <div class="flex justify-center gap-4 mt-6">
                <a href="?action=start" class="bg-green-500 text-white px-4 py-2 rounded-full shadow hover:bg-green-600">▶️ Start</a>
                <a href="?action=stop" class="bg-yellow-500 text-white px-4 py-2 rounded-full shadow hover:bg-yellow-600">⏸️ Stop</a>
                <a href="?action=restart" class="bg-red-500 text-white px-4 py-2 rounded-full shadow hover:bg-red-600">🔁 Restart</a>
            </div>
        </div>

        <!-- Log Panel -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-2">📜 Operation Log</h2>
            <div class="max-h-64 overflow-y-auto text-sm space-y-2">
                <% for (int j = operationLog.size() - 1; j >= 0; j--) { %>
                    <div class="border-b border-gray-200 pb-1"><%= operationLog.get(j) %></div>
                <% } %>
            </div>
        </div>

        <!-- Graph Panel -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-2">📈 Buffer Usage Graph</h2>
            <canvas id="bufferChart" width="400" height="200"></canvas>
            <script>
                const ctx = document.getElementById('bufferChart').getContext('2d');
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: [...Array(<%= bufferHistory.size() %>).keys()],
                        datasets: [{
                            label: 'Buffer Size',
                            data: [<%= String.join(",", bufferHistory.stream().map(Object::toString).toArray(String[]::new)) %>],
                            borderColor: 'rgba(75, 192, 192, 1)',
                            backgroundColor: 'rgba(75, 192, 192, 0.2)',
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        scales: {
                            y: { beginAtZero: true, max: <%= MAX_SIZE %> }
                        }
                    }
                });
            </script>
        </div>
    </div>
    <a href="homee.html" class="fixed bottom-6 right-6 group">
        <div class="bg-indigo-600 text-white px-6 py-3 rounded-full shadow-lg transform transition-all duration-300 ease-in-out group-hover:scale-105 group-hover:bg-indigo-700">
          ⬅ Back to Home
        </div>
      </a>
      
</body>
</html>
