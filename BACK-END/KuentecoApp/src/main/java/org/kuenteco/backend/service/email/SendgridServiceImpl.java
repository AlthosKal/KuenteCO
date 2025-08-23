package org.kuenteco.backend.service.email;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Email;
import com.sendgrid.helpers.mail.objects.Personalization;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;
import org.kuenteco.backend.dto.auth.ValidateVerificationCodeDTO;
import org.kuenteco.backend.exception.exceptions.SendgridException;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.user.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class SendgridServiceImpl implements SendgridService {
    protected final Map<String, String> verificationCodes = new ConcurrentHashMap<>();
    private final SlaveUserRepository slaveUserRepository;
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final UserService userService;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SecureRandom random = new SecureRandom();

    // SendGrid
    @Value("${spring.sendgrid.api-key}")
    private String sendgridApiKey;

    @Value("${spring.sendgrid.email}")
    private String emailSendGrid;

    @Value("${spring.sendgrid.functions.verify-email}")
    private String verifyEmail;

    @Value("${spring.sendgrid.functions.reset-password}")
    private String resetPassword;

    @Override
    public void sendVerificationEmail(
            SendVerificationCodeDTO sendVerificationCodeDTO, boolean isRegistration) {
        String email =
                Optional.ofNullable(sendVerificationCodeDTO.getEmail())
                        .filter(
                                e ->
                                        isRegistration && slaveUserRepository.existsByEmail(e)
                                                || isRegistration
                                                        && slaveProfileRepository.existsByEmail(e))
                        .orElseThrow(
                                () ->
                                        new SendgridException(
                                                isRegistration
                                                        ? "Email no registrado"
                                                        : "Email no válido"));

        String code = generateVerificationCode();
        verificationCodes.put(email, code);
        log.info("Código de verificacion: {}", code);

        // Programar la eliminación del código después de 15 minutos
        scheduleRemoval(email);

        try {
            sendEmail(email, code, isRegistration);
        } catch (IOException e) {
            verificationCodes.remove(email);
            throw new SendgridException("Error al enviar email: " + e.getMessage());
        }
    }

    @Override
    public boolean validateVerificationCode(
            ValidateVerificationCodeDTO validateVerificationCodeDTO) {
        String storedCode = verificationCodes.get(validateVerificationCodeDTO.getEmail());
        String code = validateVerificationCodeDTO.getCode();
        return code != null && code.equals(storedCode);
    }

    private void scheduleRemoval(String email) {
        scheduler.schedule(() -> verificationCodes.remove(email), 15, TimeUnit.MINUTES);
        scheduler.schedule(() -> userService.deletePendingEmail(email), 15, TimeUnit.MINUTES);
    }

    private String generateVerificationCode() {
        int value = random.nextInt(999999);
        return String.format("%06d", value);
    }

    private void sendEmail(String recipientEmail, String code, boolean isRegistration)
            throws IOException {
        Mail mail = getMail(recipientEmail, code, isRegistration);

        SendGrid sg = new SendGrid(sendgridApiKey);
        Request request = new Request();
        request.setMethod(Method.POST);
        request.setEndpoint("mail/send");
        request.setBody(mail.build());

        Response response = sg.api(request);

        if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
            log.error(
                    "Error al enviar email. Código: {}, Respuesta: {}",
                    response.getStatusCode(),
                    response.getBody());
            throw new IOException("Error en el servicio de email: " + response.getBody());
        }
    }

    private @NotNull Mail getMail(String recipientEmail, String code, boolean isRegistration) {
        Email from = new Email(emailSendGrid);
        Email to = new Email(recipientEmail);

        Mail mail = new Mail();
        mail.setFrom(from);
        mail.setSubject(isRegistration ? "Verifica tu registro" : "Recuperación de contraseña");

        Personalization personalization = new Personalization();
        personalization.addTo(to);

        String templateId = isRegistration ? verifyEmail : resetPassword;
        String dynamicField = isRegistration ? "codeVerificationEmail" : "codeResetPassword";

        personalization.addDynamicTemplateData(dynamicField, code);
        mail.addPersonalization(personalization);
        mail.setTemplateId(templateId);
        return mail;
    }
}
