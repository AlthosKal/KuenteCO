package org.kuenteco.backend.service.profile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.ChangePasswordDTO;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;

public interface ProfileService {
    TokenResponseDTO authenticate(LoginDTO dto, HttpServletResponse response);

    Object getProfiles();

    ProfileDetailDTO getProfileDetails();

    void registerProfile(NewProfileDTO dto);

    void updateProfile(UpdateProfileDTO dto);

    String changePasswordWithVerification(ChangePasswordDTO changePasswordDTO);

    void deleteProfile(Integer id);

    void logout(HttpServletRequest request, HttpServletResponse response);
}
