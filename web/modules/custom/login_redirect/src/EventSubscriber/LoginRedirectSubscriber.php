<?php

namespace Drupal\login_redirect\EventSubscriber;

use Drupal\Core\Routing\TrustedRedirectResponse;
use Drupal\Core\Url;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

/**
 * Redirects users to /admin after login.
 */
class LoginRedirectSubscriber implements EventSubscriberInterface {

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents() {
    // Run after the user module's redirect (priority lower than default).
    $events[KernelEvents::RESPONSE][] = ['onResponse', -100];
    return $events;
  }

  /**
   * Redirects to /admin after login.
   *
   * @param \Symfony\Component\HttpKernel\Event\ResponseEvent $event
   *   The response event.
   */
  public function onResponse(ResponseEvent $event) {
    $request = $event->getRequest();
    $response = $event->getResponse();

    // Check if this is a redirect response after login.
    if ($response->isRedirection()) {
      $target_url = $response->headers->get('Location');

      // Check if redirecting to user page with check_logged_in parameter.
      if ($target_url && strpos($target_url, 'check_logged_in=1') !== FALSE) {
        // Redirect to /admin instead.
        $admin_url = Url::fromRoute('system.admin')->setAbsolute()->toString();
        $event->setResponse(new TrustedRedirectResponse($admin_url));
      }
    }
  }

}
