package org.kuenteco.backend.service.profile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.profile.ChangePasswordDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.springframework.web.multipart.MultipartFile;

public interface ProfileService {
    TokenResponseDTO authenticate(LoginDTO dto, HttpServletResponse response);

    Object getProfiles();

    Object getProfileById(Integer id);

    ProfileDetailDTO getProfileDetails();

    void registerProfile(NewProfileDTO dto);

    void updateProfile(UpdateProfileDTO dto, MultipartFile file) throws IOException;

    String changePassword(ChangePasswordDTO dto);

    void deleteProfile(Integer id);

    void logout(HttpServletRequest request, HttpServletResponse response);
}
