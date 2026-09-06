"""Train MobileNetV2 on Plant Village (29 classes) with transfer learning."""
import json
import time
import sys
from pathlib import Path

import torch
import torch.nn as nn
import torch.optim as optim
import torch.backends.cudnn as cudnn

cudnn.enabled = True
cudnn.benchmark = True

from torch.utils.data import DataLoader
from torchvision import transforms, models
from torchvision.datasets import ImageFolder

# ── Config ──────────────────────────────────────────────────────────────────
NUM_CLASSES    = 29
IMG_SIZE       = 224
BATCH_SIZE     = 64
NUM_EPOCHS     = 10
LEARNING_RATE  = 1e-3
DEVICE         = torch.device("cuda" if torch.cuda.is_available() else "cpu")
DATASET_ROOT   = Path(r"E:\Agrovia V 0.1\datasets\Plant Village Dataset")
OUTPUT_DIR     = Path(r"E:\Agrovia V 0.1\app\training")
LOG_FILE       = OUTPUT_DIR / "train.log"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def log(msg):
    try:
        print(msg, flush=True)
    except UnicodeEncodeError:
        print(msg.encode('ascii', 'replace').decode('ascii'), flush=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(msg + "\n")
        f.flush()

def main():
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        f.write("=== Training Started ===\n")

    log(f"Device: {DEVICE} ({torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU'})")

    # ── Data transforms ──────────────────────────────────────────────────────────
    train_tf = transforms.Compose([
        transforms.RandomResizedCrop(IMG_SIZE, scale=(0.8, 1.0)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    train_ds = ImageFolder(str(DATASET_ROOT / "Train"), transform=train_tf)
    val_ds   = ImageFolder(str(DATASET_ROOT / "Val"),   transform=val_tf)

    train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, shuffle=True,  num_workers=0, pin_memory=False)
    val_loader   = DataLoader(val_ds,   batch_size=BATCH_SIZE, shuffle=False, num_workers=0, pin_memory=False)

    log(f"Train: {len(train_ds)} images, {len(train_loader)} batches")
    log(f"Val:   {len(val_ds)} images, {len(val_loader)} batches")

    # ── Model: MobileNetV2 with pre-trained weights & frozen backbone ───────────
    model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.IMAGENET1K_V1)
    for param in model.features.parameters():
        param.requires_grad = False
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, NUM_CLASSES)
    model = model.to(DEVICE)

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.classifier.parameters(), lr=LEARNING_RATE, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=NUM_EPOCHS, eta_min=1e-5)

    # ── Train loop ───────────────────────────────────────────────────────────────
    best_acc = 0.0
    results  = []

    for epoch in range(NUM_EPOCHS):
        t0 = time.time()
        # train
        model.train()
        running_loss, correct, total = 0.0, 0, 0
        for i, (imgs, labels) in enumerate(train_loader):
            imgs, labels = imgs.to(DEVICE), labels.to(DEVICE)
            optimizer.zero_grad()

            out  = model(imgs)
            loss = criterion(out, labels)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.classifier.parameters(), max_norm=1.0)
            optimizer.step()

            running_loss += loss.item() * imgs.size(0)
            _, pred = out.max(1)
            correct += pred.eq(labels).sum().item()
            total   += labels.size(0)

            if (i + 1) % 100 == 0 or (i + 1) == len(train_loader):
                log(f"Epoch [{epoch+1:02d}/{NUM_EPOCHS}] Batch [{i+1:03d}/{len(train_loader)}] Loss: {running_loss/total:.4f} Acc: {correct/total:.4f}")

        train_loss = running_loss / total
        train_acc  = correct / total

        # val
        model.eval()
        running_loss, correct, total = 0.0, 0, 0
        with torch.no_grad():
            for imgs, labels in val_loader:
                imgs, labels = imgs.to(DEVICE), labels.to(DEVICE)
                out  = model(imgs)
                loss = criterion(out, labels)

                running_loss += loss.item() * imgs.size(0)
                _, pred = out.max(1)
                correct += pred.eq(labels).sum().item()
                total   += labels.size(0)
        val_loss = running_loss / total
        val_acc  = correct / total
        scheduler.step()
        elapsed = time.time() - t0

        log(f"--> Epoch {epoch+1:02d}/{NUM_EPOCHS} Finished: train_loss={train_loss:.4f} train_acc={train_acc:.4f} val_loss={val_loss:.4f} val_acc={val_acc:.4f} time={elapsed:.0f}s")

        results.append({
            "epoch": epoch+1,
            "train_loss": train_loss, "train_acc": train_acc,
            "val_loss":   val_loss,   "val_acc":   val_acc,
            "elapsed_s":  elapsed,
        })

        if val_acc > best_acc:
            best_acc = val_acc
            torch.save(model.state_dict(), OUTPUT_DIR / "best_model.pth")
            log(f"  * New best val_acc={val_acc:.4f} - checkpoint saved to best_model.pth")

    torch.save(model.state_dict(), OUTPUT_DIR / "final_model.pth")

    with open(OUTPUT_DIR / "training_history.json", "w") as f:
        json.dump({"results": results, "best_val_acc": best_acc}, f, indent=2)

    log(f"\nTraining done. Best val_acc={best_acc:.4f}")
    log(f"Checkpoints: {OUTPUT_DIR / 'best_model.pth'}, {OUTPUT_DIR / 'final_model.pth'}")

if __name__ == "__main__":
    main()