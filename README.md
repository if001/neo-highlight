# neo-highlight

Highlight the node corresponding to the current buffer's file in NeoTree,
without moving point/cursor in the NeoTree buffer.

## Install (use-package)

Assuming you use straight.el:

```elisp
(use-package neo-highlight
  :straight (neo-highlight
             :type git
             :host github
             :repo "https://github.com/if001/neo-highlight.git")
  :after neotree
  :config
  (neo-highlight-mode 1))
```

## Customize face

```elisp
(custom-set-faces
 '(neo-highlight-current-file-face ((t (:inherit hl-line :underline t)))))
```


## Disable buffer-change updates

```elisp
(setq neo-highlight-update-on-buffer-change nil)
```
