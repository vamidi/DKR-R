// Switch phase 1: the built-in updater has no HTTPS transport on homebrew
// and no child-process installer. The update service catches this and
// reports the check as failed, matching the gated-feature contract.
#include "../game/updates/update_http.hpp"
#include <stdexcept>

namespace dkr::updates {
HttpResponse https_get(const HttpRequest &, std::stop_token, const Progress &) {
    throw std::runtime_error("Automatic updates are not supported on Switch.");
}
} // namespace dkr::updates