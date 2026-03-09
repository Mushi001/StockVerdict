package org.henriette.stockverdict;

import java.io.*;

import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

/**
 * A simple "Hello World" Servlet used for initial testing and health checks.
 * Mapped to the <code>/hello-servlet</code> endpoint.
 */
@WebServlet(name = "helloServlet", value = "/hello-servlet")
public class HelloServlet extends HttpServlet {
    private String message;

    /**
     * Initializes the servlet and sets the default greeting message.
     */
    @Override
    public void init() {
        message = "Hello World!";
    }

    /**
     * Handles HTTP GET requests by returning a simple HTML page containing the greeting message.
     *
     * @param request  the HTTP request
     * @param response the HTTP response
     * @throws IOException if an output error occurs while writing the response
     */
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html");

        // Hello
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>" + message + "</h1>");
        out.println("</body></html>");
    }

    /**
     * Performs cleanup when the servlet is being destroyed.
     */
    @Override
    public void destroy() {
    }
}