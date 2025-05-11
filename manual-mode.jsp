<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    final int MAX_SIZE = 5;

    // Retrieve session attributes or initialize them
    Queue<String> buffer = (Queue<String>) session.getAttribute("buffer");
    List<String> operationLog = (List<String>) session.getAttribute("operationLog");
    List<Integer> bufferHistory = (List<Integer>) session.getAttribute("bufferHistory");
    Integer producerCount = (Integer) session.getAttribute("producerCount");
    Integer consumerCount = (Integer) session.getAttribute("consumerCount");
    Integer producerWaits = (Integer) session.getAttribute("producerWaits");
    Integer consumerWaits = (Integer) session.getAttribute("consumerWaits");

    if (buffer == null) {
        buffer = new LinkedList<>();
        session.setAttribute("buffer", buffer);
    }
    if (operationLog == null) {
        operationLog = new ArrayList<>();
        session.setAttribute("operationLog", operationLog);
    }
    if (bufferHistory == null) {
        bufferHistory = new ArrayList<>();
        session.setAttribute("bufferHistory", bufferHistory);
    }
    if (producerCount == null) {
        producerCount = 1;
        session.setAttribute("producerCount", producerCount);
    }
    if (consumerCount == null) {
        consumerCount = 1;
        session.setAttribute("consumerCount", consumerCount);
    }
    if (producerWaits == null) {
        producerWaits = 0;
        session.setAttribute("producerWaits", producerWaits);
    }
    if (consumerWaits == null) {
        consumerWaits = 0;
        session.setAttribute("consumerWaits", consumerWaits);
    }

    String action = request.getParameter("action");
    String result = "";

    if ("produce".equals(action)) {
        String producer = "Producer-" + producerCount;
        int item = new Random().nextInt(100);

        if (buffer.size() >= MAX_SIZE) {
            result = "⏳ " + producer + " wants to produce item: " + item + ", but buffer is full. Waiting...";
            producerWaits++;
            session.setAttribute("producerWaits", producerWaits);
        } else {
            String entry = item + " (" + producer + ")";
            buffer.add(entry);
            result = "✅ " + producer + " produced item: " + item;
            producerCount++;
            session.setAttribute("producerCount", producerCount);
        }

        operationLog.add(result);
        bufferHistory.add(buffer.size());

    } else if ("consume".equals(action)) {
        String consumer = "Consumer-" + consumerCount;

        if (buffer.isEmpty()) {
            result = "⏳ " + consumer + " tried to consume, but buffer is empty. Waiting...";
            consumerWaits++;
            session.setAttribute("consumerWaits", consumerWaits);
        } else {
            String removed = buffer.poll();
            result = "✅ " + consumer + " consumed item: " + removed;
            consumerCount++;
            session.setAttribute("consumerCount", consumerCount);
        }

        operationLog.add(result);
        bufferHistory.add(buffer.size());

    } else if ("reset".equals(action)) {
        buffer.clear();
        operationLog.clear();
        bufferHistory.clear();
        producerCount = 1;
        consumerCount = 1;
        producerWaits = 0;
        consumerWaits = 0;
        session.setAttribute("producerCount", producerCount);
        session.setAttribute("consumerCount", consumerCount);
        session.setAttribute("producerWaits", producerWaits);
        session.setAttribute("consumerWaits", consumerWaits);
        result = "🔄 Buffer and counters have been reset.";
        operationLog.add(result);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manual Producer-Consumer Simulation</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="min-h-screen bg-gradient-to-br from-indigo-50 via-gray-100 to-teal-50 flex flex-col items-center font-sans p-6">

    <div class="grid grid-cols-2 gap-6 w-full max-w-6xl">
        <!-- 📊 Performance Metrics -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-indigo-700 mb-4">📊 Performance Metrics</h2>
            <div class="grid grid-cols-2 gap-4 text-center">
                <div class="bg-blue-100 p-4 rounded-xl shadow">
                    <strong>Total Produced</strong><br><%= producerCount - 1 %>
                </div>
                <div class="bg-blue-100 p-4 rounded-xl shadow">
                    <strong>Total Consumed</strong><br><%= consumerCount - 1 %>
                </div>
                <div class="bg-blue-100 p-4 rounded-xl shadow">
                    <strong>Buffer Usage</strong><br><%= (int)(((double)buffer.size()/MAX_SIZE)*100) %> %
                </div>
                <div class="bg-blue-100 p-4 rounded-xl shadow">
                    <strong>Waits (P/C)</strong><br><%= producerWaits %> / <%= consumerWaits %>
                </div>
            </div>
        </div>

        <!-- 📦 Current Buffer State + Controls -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-2">📦 Current Buffer</h2>
            <div class="flex flex-wrap justify-center gap-2">
                <% int i = 0; for (String item : buffer) { %>
                    <div class="w-28 h-14 flex items-center justify-center bg-white border border-indigo-500 rounded-lg shadow text-sm"><%= item %></div>
                <% i++; } while (i < MAX_SIZE) { %>
                    <div class="w-28 h-14 flex items-center justify-center bg-gray-200 border border-dashed rounded-lg text-gray-500">Empty</div>
                <% i++; } %>
            </div>

            <form method="post" class="flex justify-center gap-4 mt-6">
                <button name="action" value="produce" class="bg-green-500 text-white px-4 py-2 rounded-full shadow hover:bg-green-600">➕ Produce</button>
                <button name="action" value="consume" class="bg-yellow-500 text-white px-4 py-2 rounded-full shadow hover:bg-yellow-600">➖ Consume</button>
                <button name="action" value="reset" class="bg-red-500 text-white px-4 py-2 rounded-full shadow hover:bg-red-600">🔄 Reset</button>
            </form>
        </div>

        <!-- 📜 Operation Log -->
        <div class="bg-white p-6 rounded-xl shadow col-span-2 md:col-span-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-2">📜 Operation Log</h2>
            <div class="max-h-64 overflow-y-auto text-sm space-y-2">
                <% for (int j = operationLog.size() - 1; j >= 0; j--) { %>
                    <div class="border-b border-gray-200 pb-1"><%= operationLog.get(j) %></div>
                <% } %>
            </div>
        </div>

        <!-- 📈 Buffer Usage Graph -->
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
    <a href="index.html" class="fixed bottom-6 right-6 group">
        <div class="bg-indigo-600 text-white px-6 py-3 rounded-full shadow-lg transform transition-all duration-300 ease-in-out group-hover:scale-105 group-hover:bg-indigo-700">
          ⬅ Back to Home
        </div>
      </a>
</body>
</html>
