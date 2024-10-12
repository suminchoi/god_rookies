<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shashi.service.impl.*, com.shashi.service.*,com.shashi.beans.*,java.util.*,javax.servlet.ServletOutputStream,java.io.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Payments</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/changes.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/3.1.9-1/crypto-js.js"></script>
    <script>
        function encryptPaymentDetails() {
            var cardholder = document.getElementById('cardholder').value;
            var cardnumber = document.getElementById('cardnumber').value;
            var cvv = document.getElementById('cvv').value;
            var expmonth = document.getElementById('expmonth').value;
            var expyear = document.getElementById('expyear').value;

            var key = CryptoJS.enc.Utf8.parse('rookies-key12345');
            
            var encryptedCardholder = CryptoJS.AES.encrypt(cardholder, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7 // 패딩 방식을 명시적으로 추가
            }).toString();
            var encryptedCardnumber = CryptoJS.AES.encrypt(cardnumber, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7 // 패딩 방식을 명시적으로 추가
            }).toString();
            var encryptedCVV = CryptoJS.AES.encrypt(cvv, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7 // 패딩 방식을 명시적으로 추가
            }).toString();
            var encryptedExpmonth = CryptoJS.AES.encrypt(expmonth, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7 // 패딩 방식을 명시적으로 추가
            }).toString();
            var encryptedExpyear = CryptoJS.AES.encrypt(expyear, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7 // 패딩 방식을 명시적으로 추가
            }).toString();

            document.getElementById('encryptedCardholder').value = encryptedCardholder;
            document.getElementById('encryptedCardnumber').value = encryptedCardnumber;
            document.getElementById('encryptedCVV').value = encryptedCVV;
            document.getElementById('encryptedExpmonth').value = encryptedExpmonth;
            document.getElementById('encryptedExpyear').value = encryptedExpyear;

            // 원래 필드 값은 유지하여 사용자에게 보이게 함
        }
    </script>
</head>
<body style="background-color: #E6F9E6;">
<%
    String userName = (String) session.getAttribute("username");
    String password = (String) session.getAttribute("password");

    if (userName == null || password == null) {
        response.sendRedirect("login.jsp?message=Session Expired, Login Again!!");
        return; 
    }

    String sAmount = request.getParameter("amount");
    double amount = 0;

    if (sAmount != null) {
        try {
            amount = Double.parseDouble(sAmount);
        } catch (NumberFormatException e) {
            out.println("<script>alert('Invalid amount format!');</script>");
        }
    }
%>

<jsp:include page="header.jsp" />

<div class="container">
    <div class="row" style="margin-top: 5px; margin-left: 2px; margin-right: 2px;">
        <form action="./OrderServlet" method="post" class="col-md-6 col-md-offset-3"
              style="border: 2px solid black; border-radius: 10px; background-color: #FFE5CC; padding: 10px;" onsubmit="encryptPaymentDetails()">
            <div style="font-weight: bold;" class="text-center">
                <div class="form-group">
                    <img src="images/profile.jpg" alt="Payment Proceed" height="100px" />
                    <h2 style="color: green;">Credit Card Payment</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 form-group">
                    <label for="cardholder">Name of Card Holder</label>
                    <input type="text" placeholder="Enter Card Holder Name" name="cardholder" class="form-control" id="cardholder" required>
                    <input type="hidden" id="encryptedCardholder" name="encryptedCardholder">
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 form-group">
                    <label for="cardnumber">Enter Credit Card Number</label>
                    <input type="text" placeholder="4242-4242-4242-4242" name="cardnumber" class="form-control" id="cardnumber" required>
                    <input type="hidden" id="encryptedCardnumber" name="encryptedCardnumber">
                </div>
            </div>
            <div class="row">
                <div class="col-md-6 form-group">
                    <label for="expmonth">Expiry Month</label>
                    <input type="number" placeholder="MM" name="expmonth" class="form-control" size="2" max="12" min="1" id="expmonth" required>
                    <input type="hidden" id="encryptedExpmonth" name="encryptedExpmonth">
                </div>
                <div class="col-md-6 form-group">
                    <label for="expyear">Expiry Year</label>
                    <input type="number" placeholder="YYYY" class="form-control" size="4" id="expyear" name="expyear" required>
                    <input type="hidden" id="encryptedExpyear" name="encryptedExpyear">
                </div>
            </div>
            <div class="row text-center">
                <div class="col-md-6 form-group">
                    <label for="cvv">Enter CVV</label>
                    <input type="text" placeholder="123" class="form-control" size="3" id="cvv" name="cvv" required>
                    <input type="hidden" id="encryptedCVV" name="encryptedCVV">
                    <input type="hidden" name="amount" value="<%=amount%>">
                </div>
                <div class="col-md-6 form-group">
                    <label>&nbsp;</label>
                    <button type="submit" class="form-control btn btn-success">Pay : Rs <%=amount%></button>
                </div>
            </div>
        </form>
    </div>
</div>

<%@ include file="footer.html" %>
</body>
</html>
