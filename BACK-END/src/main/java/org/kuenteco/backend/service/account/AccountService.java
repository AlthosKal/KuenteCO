package org.kuenteco.backend.service.account;

import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface AccountService {
    List<AccountDetailDTO> getAccounts();

    void registerAccount(NewAccountDTO newAccountDTO, String username) throws IOException;

    void deleteAccount(MasterAccount account) throws IOException;

    ImageDTO saveImage(MultipartFile image, MasterAccount masterAccount, HttpServletResponse response);
    ImageDTO updateImage(MultipartFile image, MasterAccount masterAccount, HttpServletResponse response);
    void deleteImage(MasterAccount masterAccount, HttpServletResponse response);
}
