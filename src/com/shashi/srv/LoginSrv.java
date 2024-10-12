package com.shashi.srv;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.shashi.beans.UserBean;
import com.shashi.service.impl.UserServiceImpl;
import java.util.Base64;

@WebServlet("/LoginSrv")
public class LoginSrv extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String SECRET_KEY = "rookies-key12345"; // 대칭키, 클라이언트와 동일하게 설정
    private static final String ALLOWED_ADMIN_IP = "192.168.43.1"; // 허용된 IP 주소 (변경 가능)
    private static Map<String, HttpSession> activeSessions = new HashMap<>(); // 활성 세션 관리

    // AES 복호화 메소드
    private String decrypt(String encryptedData) throws Exception {
        SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(), "AES");
        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        
        byte[] decodedData = Base64.getDecoder().decode(encryptedData);
        byte[] decryptedData = cipher.doFinal(decodedData);
        return new String(decryptedData).trim();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String encryptedUserName = request.getParameter("encryptedUsername");
        String encryptedPassword = request.getParameter("encryptedPassword");
        String userType = request.getParameter("usertype");
        response.setContentType("text/html");

        String userName = null;
        String password = null;

        try {
            // 암호화된 값 복호화
            userName = decrypt(encryptedUserName);
            password = decrypt(encryptedPassword);
        } catch (Exception e) {
            e.printStackTrace();
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp?message=Decryption Failed");
            rd.forward(request, response);
            return;
        }

        String status;

        if ("admin".equals(userType)) {
            // Admin 로그인 시 클라이언트 IP 확인
            String clientIP = request.getRemoteAddr(); // 클라이언트 IP 가져오기
            if (!clientIP.equals(ALLOWED_ADMIN_IP)) {
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp?message=Access Denied! Invalid IP Address.");
                rd.forward(request, response);
                return;
            }

            // 허용된 IP일 경우 관리자 로그인 처리
            if ("rookies20@gmail.com".equals(userName) && "qweQWE123!@#".equals(password)) {
                HttpSession session = request.getSession();
                session.setAttribute("username", userName);
                session.setAttribute("password", password);
                session.setAttribute("usertype", userType);
                saveSession(userName, session);
                createEncryptedUserCookie(response, userName, password); // 쿠키 생성

                RequestDispatcher rd = request.getRequestDispatcher("rookiesViewProduct.jsp");
                rd.forward(request, response);
                return;
            } else {
                status = "Login Denied! Invalid Admin Username or Password.";
            }
        } else {
            // Customer Login
            UserServiceImpl udao = new UserServiceImpl();
            status = udao.isValidCredential(userName, password);
            if ("valid".equalsIgnoreCase(status)) {
                UserBean user = udao.getUserDetails(userName, password);

                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("userdata", user);
                newSession.setAttribute("username", userName);
                newSession.setAttribute("password", password);
                newSession.setAttribute("usertype", userType);
                saveSession(userName, newSession);
                createEncryptedUserCookie(response, userName, password); // 쿠키 생성

                RequestDispatcher rd = request.getRequestDispatcher("userHome.jsp");
                rd.forward(request, response);
                return;
            } else {
                status = "Login Denied! Invalid Username or Password.";
            }
        }

        RequestDispatcher rd = request.getRequestDispatcher("login.jsp?message=" + status);
        rd.forward(request, response);
    }

    // 사용자 세션 저장 및 이전 세션 무효화
    private void saveSession(String userName, HttpSession session) {
        if (activeSessions.containsKey(userName)) {
            HttpSession oldSession = activeSessions.get(userName);
            if (oldSession != null) {
                try {
                    oldSession.invalidate(); // 이전 세션 무효화
                } catch (IllegalStateException e) {
                    // 세션이 이미 무효화된 경우 예외 무시
                }
            }
        }
        activeSessions.put(userName, session); // 현재 세션 저장
    }

    // AES 암호화 메소드
    private String encrypt(String data) {
        try {
            SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(), "AES");
            Cipher cipher = Cipher.getInstance("AES");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            byte[] encryptedData = cipher.doFinal(data.getBytes());
            return Base64.getEncoder().encodeToString(encryptedData);
        } catch (Exception e) {
            throw new RuntimeException("Error encrypting data", e);
        }
    }

    // 암호화된 쿠키 생성 및 설정
    private void createEncryptedUserCookie(HttpServletResponse response, String userName, String password) {
        try {
            long currentTimeMillis = System.currentTimeMillis();
            String cookieValue = userName + ":" + password + ":" + currentTimeMillis;

            String encryptedCookieValue = encrypt(cookieValue);

            Cookie userCookie = new Cookie("userCookie", encryptedCookieValue);
            userCookie.setMaxAge(60 * 60 * 24); // 1일 동안 유지
            userCookie.setHttpOnly(true);
            response.addCookie(userCookie);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
